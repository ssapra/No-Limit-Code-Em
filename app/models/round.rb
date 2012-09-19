class Round < ActiveRecord::Base
  include RubyPoker
  attr_accessible :first_bet, 
                  :min_bet, 
                  :pot, 
                  :second_bet, 
                  :table_id
                  
  belongs_to :table
  
  def setup
    player_ids = self.players_in.map {|player| player.id}
    log_player_state
    dealer_seat_id = self.set_dealer 
    HandLog.create(:hand_id => self.id, :table_id => table.id, :players_ids => player_ids.join(",").gsub(","," "), :dealer_seat_id => dealer_seat_id)
    self.ante_up
    self.table.deal_cards
    self.table.save
    self.next_action
  end
  
  def set_dealer
    if self.table.dealer_id
      seat = Player.find_by_id(self.table.dealer_id).seat
      next_seat = seat.next_seat
      self.table.update_attributes(:dealer_id => next_seat.player.id )        # Next dealer set up
      return next_seat.id
    else
      self.table.update_attributes(:dealer_id => self.players_in[0].id)     # First dealer is set at first player in array
      seat = Player.find_by_id(self.table.dealer_id).seat
      return seat.id
    end
  end
  
  def ante_up
    self.players_in.each do |player|
      if player.stack >= ServerApp::Application.config.ANTE
        ante = ServerApp::Application.config.ANTE
        self.update_attributes(:pot => self.pot+= ante)   
        player.stack-= ante
        player.bet+= ante
        player.save
        PlayerActionLog.create(:hand_id => self.id,
                             :player_id => player.id,
                             :action => "ante",
                             :amount => ante)
      else
        self.update_attributes(:pot => self.pot+= player.stack)   
        player.stack-= player.stack
        player.bet+= player.stack
        player.save
        PlayerActionLog.create(:hand_id => self.round.id,
                               :player_id => player.id,
                               :action => "lost",
                               :comment => "could not match ante")
      end                         
    end
  end
  
  def minimum_bet
    min_bet = 0
    self.players_in.each do |player|
      if player.bet > min_bet # Checks the bets of players who have bet
          min_bet = player.bet
      end 
    end
    self.min_bet = min_bet
    self.save
    return min_bet
  end
  
  def next_seat                                   # Moves dealer or finds next active player for betting/replacement
    if self.table.turn_id
      seat = Player.find_by_id(self.table.turn_id).seat
      return seat.next_seat                       # If turn_id exists, next active player's seat is sent back
    else                                          # If there's already a dealer, the person left of the dealer starts betting
      seat = Player.find_by_id(self.table.dealer_id).seat
      return seat.next_seat
    end
  end
  
  def next_action
    if self.players_in.count == 1                             
      logger.debug "ONLY 1 PLAYER LEFT"
      self.determine_winner
    elsif self.players_ready?                      # Determines if players are ready for replacment or showdown
      logger.debug "PLAYERS READY"
      if self.second_bet
        logger.debug "DETERMINING WINNER"
        self.determine_winner
      else
        logger.debug "STARTING REPLACEMENT"
        self.table.deck.deal                  # Burning one card before starting replacement
        self.table.turn_id = nil              # Resets order to start with whoever started betting round
        self.table.save
        self.next_replacement
      end
    else
      # logger.debug "TABLE BEFORE FIRST PLAYER RETURNED: #{self.inspect}"
      player = self.next_seat.player        # Finds next player who is in the game
      
      if player.action.nil? || player.bet != self.minimum_bet 
        self.table.turn_id = player.id
        self.table.save
        logger.debug "Player Turn: #{player.name}"
      else                                 # If player is all good, move on to next player.
        self.next_action
      end
    end  
  end
  
  def next_replacement
    if self.players_in.count == 1         # If someone messes up replacement and only 1 person left, we stop                    
      logger.debug "ONLY 1 PLAYER LEFT"
      self.determine_winner
    elsif self.finished_replacement?          # If everyone has their replacement attribute switched to true
      logger.debug "REPLACEMENT FINISHED"
      self.update_attributes(:second_bet => true)
      self.table.update_attributes(:turn_id => nil)
      self.replacement_finished                 # Replacement attribute set to false again
      self.next_action
    else    
      player = self.next_seat.player
      self.table.turn_id = player.id
      self.table.save
      player.replacement = true
      player.save
      logger.debug "Replacement Turn: #{player.name}"
    end  
  end
  
  def finished_replacement?
    # players = self.players.select {|player| player.in_round}
    self.players_in.each do |player|  
      if player.replacement == false
        return false
      end
    end
    true
  end
  
  def replacement_finished
    self.players_in.each do |player|
      player.replacement = false
      player.save
    end
  end
  
  def determine_winner
    self.table.turn_id = nil                                  # Nobody's turn now. 
    self.save
    self.players_in.each do |player|
      player.change_hand_to_PokerHand
      logger.debug "#{player.name}'s hand: #{player.hand}"
    end
    
    winner = self.players_in.max {|a,b| a.hand <=> b.hand }      # Find best hand
    winners = []  
    self.players_in.each do |player|                             # Find everyone who ties the best hand
      if player.hand == winner.hand then winners << player end                  
    end
    if winners.count == 1
        logger.debug "#{winners[0].name} has won this round with #{winners[0].hand}."
        logger.debug "#{winners[0].name} wins #{pot} chips"
        winner.stack+= self.pot
        winner.save
        PlayerActionLog.create(:hand_id => self.id,
                               :player_id => winner.id,
                               :action => "win",
                               :amount => self.pot,
                               :comment => "with #{winner.hand.rank}")
    else 
        division = winners.count
        logger.debug  "The pot is split #{division}-way."
        winners.each do |winner|
          logger.debug  "#{winner.name} takes #{pot/division} with #{winner.hand}"  # NEED TO REMEMBER TO KEEP EXTRA CHIPS IN POT FOR NEXT ROUND
          winner.stack+= self.pot/division 
          winner.save
          PlayerActionLog.create(:hand_id => self.id,
                                 :player_id => winner.id,
                                 :action => "win",
                                 :amount => self.pot/division,
                                 :comment => "with #{winner.hand.rank}")         
        end
    end
    self.table.reset_players
  end
  
  def players_in
    self.table.players.select {|player| player.in_round}
  end
  
  def players_ready?
    min_bet = self.minimum_bet                  # Minimum bet re-checked
    self.players_in.each do |player|
      if player.action.nil? || player.bet != min_bet    # Checks if player has done something and match the minimum 
        return false                          # NEED TO CONSIDER IF THEY ARE ALL IN
      end
    end
    return true
  end
  
  private
    
    def log_player_state
      self.players_in.each do |player|
        PlayerStateLog.create(:hand_id => self.id, :player_id => player.id, :chip_count => player.stack)
      end
    end
end

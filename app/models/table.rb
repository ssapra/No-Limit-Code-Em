class Table < ActiveRecord::Base
  include RubyPoker
  attr_accessible :deck, 
                  :pot, # Not being used anymore
                  :turn_id, 
                  :min_bet, # Not being used anymore
                  :betting_round, # Not being used anymore
                  :placeholder_id, # Not being used anymore
                  :dealer_id
                  
  serialize :deck
  
  has_many :seats, :dependent => :destroy
  has_many :players, :through => :seats
  has_many :rounds, :dependent => :destroy
  
  def round
    self.rounds.last
  end
  
  def begin_play
    Round.create(:pot => 0, 
                 :min_bet => 0, 
                 :first_bet => true, 
                 :second_bet => false, 
                 :table_id => self.id)
                 
    self.round.setup
  end
  
  def deal_cards 
    player_ids = self.round.players_in.map {|player| player.id}
    dealer_position = player_ids.index(self.dealer_id)
    players = self.round.players_in
    ordered_players = players.push(players.shift(dealer_position+1)).flatten   # Orders players based on dealer position
    5.times do 
        ordered_players.each do |player|    
          player.hand << self.deal
          player.save!
      end
    end
    log_dealt_cards(ordered_players)
  end
  
  def deal
    self.deck.deal.to_s.gsub(/-/,"") .gsub(/'/," ")
  end
  
  def reset_players                   # Called after a winner has been declared
    players = self.players.select {|player| player.in_game}
    players.each do |player|
      player.bet = 0
      player.action = nil
      player.hand = []
      if player.stack == 0            # If player loses everything, in_game set to false, seat won't be called upon
        player.in_game = false
        player.in_round = false
      else
        player.in_round = true        # Otherwise, back in the game baby...
      end
      player.replacement = false
      player.save
    end
    self.update_attributes(:deck => Deck.new)
    
    players_in_game = self.players.select {|player| player.in_game}
    
    # if players_in_game.count <= empty_seats || players_in_game.count == 1
    #        logger.debug "We have a winner: #{players_in_game[0].name}"
    #        if Status.first.waiting == false
    #          # Status.first.waiting = true
    #          # Reassign players now
    #        else
    #          while Status.first.waiting == true
    #            if Status.first.waiting == false && players_in_game.count <= empty_seats
    #               # Status.first.waiting = true
    #               # Reassign more players
    #            end
    #          end
    #        end
    #     end
         
    if Status.first.waiting                   # Checks if tables are being reassigned
      while(Status.first.waiting == true)     # Waits to start next hand
        if Status.first.waiting == false
          logger.debug "DEALING CARDS FOR NEXT ROUND"
          self.begin_play
        end
      end
    else
      logger.debug "DEALING CARDS FOR NEXT ROUND"
      self.begin_play
    end
  end
  
  private
    
    def log_dealt_cards(ordered_players)
      ordered_players.each do |player|
        PlayerActionLog.create(:hand_id => self.round.id,
                               :player_id => player.id,
                               :action => "dealt",
                               :cards => player.hand.join(",").gsub(","," "))
      end
    end
end
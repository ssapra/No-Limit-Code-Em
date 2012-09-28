class Table < ActiveRecord::Base
  include RubyPoker
  include TableManager
  attr_accessible :deck, 
                  :pot, # Not being used anymore
                  :turn_id, 
                  :min_bet, # Not being used anymore
                  :betting_round, # Not being used anymore
                  :placeholder_id, # Not being used anymore, useless
                  :dealer_id,
                  :game_over
                  
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
      player.reload
      player.bet = 0
      player.action = nil
      if player.stack == 0          # If player loses everything, in_game set to false, seat won't be called upon
        PlayerActionLog.create(:hand_id => self.round.id,
                               :player_id => player.id,
                               :action => "lost")
        player.in_game = false
        player.seat.player_id = nil
        player.in_round = false
        player.seat.save
        player.save
        # player.destroy
      else
        player.hand = []
        player.in_round = true        # Otherwise, back in the game baby...
        player.replacement = false
        player.save
      end
    end
    self.update_attributes(:deck => Deck.new)
    
    logger.debug "CHECKPOINT"
    count_of_players = 0
    self.players.each do |player|
      player.reload
      if player.in_game
        count_of_players+=1
      end
    end
    logger.debug "Players in game: #{count_of_players}"
    status = Status.first
    status.reload
      if Status.first.waiting == true
        while(Status.first.waiting)
          Status.first.reload
            if Status.first.waiting == false 
              logger.debug "DEALING CARDS FOR NEXT ROUND"
              self.begin_play
            end
        end
      elsif (count_of_players == 1 && multiple_tables?) || (shuffle_to_one_table? && Table.all.count > 1)
      logger.debug "setup tables"
      status = Status.first
      status.update_attributes(:waiting => true)
      while(!all_tables_ready?)
        if (all_tables_ready?)
          setup_tables
          Status.first.update_attributes(:waiting => false)
        end
      end
    elsif count_of_players == 1 && Table.all.count == 1
      logger.debug ("GAME OVER")
      PlayerActionLog.create(:hand_id => self.round.id,
                             :player_id => Player.find_by_in_game(true).id,
                             :action => "won",
                             :comment => ". Tournament is over")
      self.find_winners
      Status.first.update_attributes(:game => false)
    else
      logger.debug "DEALING CARDS FOR NEXT ROUND"
      self.begin_play
    end
  end
  
  def shuffle_to_one_table?
    Player.all.select {|player| player if player.in_game}.count <= 6
  end
  
  def all_tables_ready?
    Table.all.each do |table|
      if table.turn_id != nil
        return false
      end
    end
    true
  end
      
  
  def find_winners
    first_place = Player.find_by_in_game(true)
    third_place_log = find_last_hand(3)
    second_place_log = find_last_hand(2)
    if third_place_log != second_place_log # true if (X - 3 - 2 - 1) or (X - 2 - 1) or (2 - 1)
      # if second_place_log != nil # (X - )
      if third_place_log
        loser_logs = PlayerActionLog.find_all_by_action_and_hand_id("lost", third_place_log.hand_id)
        loser_ids = loser_logs.map{|log| log.player_id}
        players = loser_ids.map {|id| Player.find_by_id(id)}
        winner = players.max {|a,b| PokerHand.new(a.hand) <=> PokerHand.new(b.hand)}      # Find best hand of the losers
        logger.debug "Third Place: #{winner.name}"
      end
      log = second_place_log.players_ids.split(" ")
      log.delete(first_place.id.to_s)
      second_place = Player.find_by_id(log[0])
      logger.debug "Second Place: #{second_place.name}"
    else
      loser_logs = PlayerActionLog.find_all_by_action_and_hand_id("lost", third_place_log.hand_id)
      loser_ids = loser_logs.map{|log| log.player_id}
      players = loser_ids.map {|id| Player.find_by_id(id)}
      ordered_losers = players.sort {|a,b| PokerHand.new(a.hand) <=> PokerHand.new(b.hand)}      # Find best hand of the losers
      logger.debug "Third Place: #{ordered_losers[1].name}"
      logger.debug "Second Place: #{ordered_losers[0].name}"
    end
    
    logger.debug "First Place: #{first_place.name}"
    
  end
  
  def find_last_hand(number_of_players)
    round_ids = self.rounds.pluck(:id)
    for round_id in round_ids.reverse
      log = HandLog.find_by_hand_id(round_id)
      if log.players_ids.split(" ").count >= number_of_players
        return log
      end
    end
    return nil
  end
  
  def multiple_tables?
    return Table.all.count > 1
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
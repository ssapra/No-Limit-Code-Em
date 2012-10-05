class Table < ActiveRecord::Base
  include RubyPoker
  include TableManager
  include ApplicationHelper
  attr_accessible :deck, 
                  :pot, # Not being used anymore
                  :turn_id, 
                  :min_bet, # Not being used anymore
                  :betting_round, # Not being used anymore
                  :placeholder_id, # Not being used anymore, useless
                  :dealer_id,
                  :waiting,
                  :game_over
                  
  serialize :deck
  
  has_many :seats, :dependent => :destroy
  has_many :players, :through => :seats
  has_many :rounds, :dependent => :destroy
  
  def round
    if self.rounds
      self.rounds.last
    else 
      nil
    end
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
    round.pot.reload
    seats = self.seats
    logger.debug "players to be dealt: #{seats.inspect}"
    seat_ids = seats.map {|seat| seat.id if seat.player}
    dealer_position = seat_ids.index(self.dealer_id)
    ordered_seats = seats.push(seats.shift(dealer_position+1)).flatten   # Orders players based on dealer position
    dealer = Seat.find_by_id(self.dealer_id)
    if dealer.player.in_game == false
      ordered_seats.delete(Seat.find_by_id(self.dealer_id))
    end
    ordered_players = ordered_seats.map {|seat| Player.find_by_id(seat.player_id)}
    live_players = ordered_players.map {|player| player if player.in_game}
    live_players -= [nil]
    logger.debug "players really being dealt: #{live_players.inspect}"
    5.times do 
        live_players.each do |player| 
          player.hand << self.deal
          player.save!
      end
    end
    log_dealt_cards(live_players)
  end
  
  def deal
    self.deck.deal.to_s.gsub(/-/,"") .gsub(/'/," ")
  end
  
  def save_losers
    players = self.players.select do |player| 
      player.reload
      player if player.in_game && player.stack == 0
    end
    
    players.sort! {|a,b| PokerHand.new(a.hand) <=> PokerHand.new(b.hand)}
    
    players.each do |player|
      player.losing_time = Time.now
      PlayerActionLog.create(:hand_id => self.round.id,
                             :player_id => player.id,
                             :action => "lost",
                             :comment => "no more chips")
      player.in_game = false
      player.seat.player_id = nil
      player.in_round = false
      player.seat.save
      player.save
    end
    
  end
  
  def reset_players                   # Called after a winner has been declared
    save_losers
    players = self.players.select {|player| player.in_game}
    players.each do |player|
      player.reload
      player.bet = 0
      player.action = nil
      player.hand = []
      player.in_round = true        # Otherwise, back in the game baby...
      player.replacement = false
      player.save
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
        self.update_attributes(:waiting => true)
        if all_tables_ready?
          logger.debug "RESHUFFLING"
          setup_tables
          Status.first.update_attributes(:waiting => false)
          Table.all.each do |table|
            table.begin_play
          end
        else
          logger.debug "NOT READY YET"
        end
      elsif (count_of_players == 1 && multiple_tables?) || (shuffle_to_one_table? && Table.all.count > 1) || standard_shuffle?
        Status.first.update_attributes(:waiting => true)
        self.update_attributes(:waiting => true)
      elsif count_of_players == 1 && Table.all.count == 1
        logger.debug ("GAME OVER")
        PlayerActionLog.create(:hand_id => self.round.id,
                               :player_id => Player.find_by_in_game(true).id,
                               :action => "won",
                               :comment => "First")
        Player.find_by_in_game(true).update_attributes(:losing_time => Time.now)
        #self.find_winners
        Table.first.update_attributes(:game_over => true)
        # Status.first.update_attributes(:game => false)
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
      table.reload
      if table.waiting == false
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
        PlayerActionLog.create(:hand_id => self.round.id,
                               :player_id => winner.id,
                               :action => "won",
                               :comment => "Third")
        # logger.debug "Third Place: #{winner.name}"
      end
      log = second_place_log.players_ids.split(" ")
      log.delete(first_place.id.to_s)
      second_place = Player.find_by_id(log[0])
      PlayerActionLog.create(:hand_id => self.round.id,
                             :player_id => second_place.id,
                             :action => "won",
                             :comment => "Second")
      # logger.debug "Second Place: #{second_place.name}"
    else
      loser_logs = PlayerActionLog.find_all_by_action_and_hand_id("lost", third_place_log.hand_id)
      loser_ids = loser_logs.map{|log| log.player_id}
      players = loser_ids.map {|id| Player.find_by_id(id)}
      ordered_losers = players.sort {|a,b| PokerHand.new(a.hand) <=> PokerHand.new(b.hand)}      # Find best hand of the losers
      PlayerActionLog.create(:hand_id => self.round.id,
                             :player_id => ordered_losers[1].id,
                             :action => "won",
                             :comment => "Third")
      PlayerActionLog.create(:hand_id => self.round.id,
                             :player_id => ordered_losers[0].id,
                             :action => "won",
                             :comment => "Second")
      # logger.debug "Third Place: #{ordered_losers[1].name}"
      # logger.debug "Second Place: #{ordered_losers[0].name}"
    end
    
    # logger.debug "First Place: #{first_place.name}"
    
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
  
  def standard_shuffle?
    if Table.all.count == 1
      return false
    else
      Table.all.each do |table|
        if table.rounds.count < ServerApp::Application.config.ROUND_LIMIT
          return false
        end
      end
      return true
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
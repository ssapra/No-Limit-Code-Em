class Table < ActiveRecord::Base
  include RubyPoker
  attr_accessible :deck, :pot, :turn_id, :min_bet
  
  serialize :deck
  
  has_many :seats, :dependent => :destroy
  has_many :players, :through => :seats
  
  def setup
    deck = Deck.new
    table_deck = [] 
    deck.size.times do
      table_deck << deck.deal.to_s.gsub(/-/,"") .gsub(/'/," ")
    end
    
    self.update_attributes(:deck => table_deck, :pot => 0)
    self.save
     
    Player.all.each do |player|
      seat = Seat.new(:table_id => self.id, :player_id => player.id)
      seat.save
      player.seat_id = seat.id
      player.hand = []
      player.save
    end
     
    5.times do 
      self.players.each do |player|  
        player.hand << self.deck.pop.to_s.gsub(/-/,"") .gsub(/'/," ")
        player.save
      end
    end
  end
  
  def current_seat
    if self.turn_id
      seat = Player.find_by_id(self.turn_id).seat
      if seat == self.seats.last
        return self.seats.first
      else
        return seat.next_seat
      end
    else
      return self.seats.first
    end
  end
  
  def next_action
    player = self.current_seat.player
      
    if player.in_game && player.in_round && (player.action.nil? || player.bet != self.minimum_bet)
      self.turn_id = player.id
      self.save
      logger.debug "Player Turn: #{Player.find_by_id(self.turn_id).name}"
    end
      
    if players_ready?
      logger.debug "PLAYERS READY"
    end
  end
  
  def players_ready?
    if self.players.count == 1
      return true
    else
      min_bet = self.minimum_bet
      still_playing = self.players.select {|player| player.in_round}
      still_playing.each do |player|
        if player.action.nil? || player.bet != min_bet
          return false
        end
      end
      return true
    end
  end
  
  def minimum_bet
    min_bet = 0
    self.players.each do |player|
      if player.in_round && player.action != nil
        if player.bet > min_bet
          min_bet = player.bet
        end
      end 
    end
    self.min_bet = min_bet
    self.save
    return min_bet
  end
  
end

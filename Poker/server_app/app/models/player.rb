class Player < ActiveRecord::Base
  include RubyPoker
  attr_accessible :game_id, 
                  :name, 
                  :player_key, 
                  :hand, 
                  :stack, 
                  :bet, 
                  :action,
                  :in_game,
                  :in_round,
                  :replacement,
                  :seat_id
                  
  serialize :hand
  
  validates :name, :uniqueness => true 
   
  belongs_to :seat
  
  def table
    seat = Seat.find_by_id(self.seat_id)
    return Table.find_by_id(seat.table_id)
  end
  
  def resolve_action(action)
    table = self.table
    min_bet = table.minimum_bet
    if action.split(" ")[0] == 'check'
      if min_bet - self.bet <= self.stack  
        self.action = "check"
        self.stack-= min_bet - self.bet
        table.pot+= min_bet - self.bet
        self.bet = min_bet
        self.save
        table.save
      else
        self.action = "fold"
        self.in_round = false
        self.save
      end
    elsif action.split(" ")[0] == 'bet'
      bet = action.split(" ")[1].to_i
      if bet + min_bet - self.bet <= self.stack && bet > 0 
        self.action = "bet"
        self.stack-= bet + min_bet - self.bet
        table.pot+= bet + min_bet - self.bet
        self.bet = min_bet + bet
        self.save
        table.save
      else
        self.action = "fold"
        self.in_round = false
        self.save
      end
    else
      self.action = "fold"
      self.in_round = false
      self.save
    end
    table.next_action
  end
  
  def replace_cards(replace)
      array_of_discards = []
      if acceptable_replacement?(replace)
        replace.each do |index|
          array_of_discards << self.hand[index.to_i-1]
        end
        self.hand-=array_of_discards
        array_of_discards.length.times do 
          self.hand << self.table.deck.deal.pop
        end
      else
        self.in_round = false
      end
  end
  
  def acceptable_replacement?(replace)
    if replace.length == replace.uniq.length
      replace.each do |number|
        if number.to_i < 1 || number.to_i > 5
          return false
        end
      end
    else
      return false
    end
    true
  end
   
end

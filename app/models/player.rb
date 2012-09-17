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
  
  def round
    table.rounds.last                     # Shortcut for getting to current round
  end
  
  def resolve_action(action, parameter)   # ALL BETTING VALIDATION LOGIC IS HERE
    round = self.table.round
    min_bet = round.minimum_bet
    if action == 'check'
      if min_bet - self.bet <= self.stack  
        self.action = "check"
        self.stack-= min_bet - self.bet
        round.pot+= min_bet - self.bet
        self.bet = min_bet
        self.save
        round.save
        PlayerActionLog.create(:hand_id => round.id, :player_id => self.id, :action => "check")
      else
        self.action = "fold"
        self.in_round = false
        self.save
        fold_action_log
      end
    elsif action == 'bet'
      bet = parameter.to_i
      # probably should have some validation that bet is not a string in the first place
      if bet + min_bet - self.bet <= self.stack && bet > 0 
        self.action = "bet"
        self.stack-= bet + min_bet - self.bet
        round.pot+= bet + min_bet - self.bet
        self.bet = min_bet + bet
        self.save
        round.save
        PlayerActionLog.create(:hand_id => round.id, :player_id => self.id, :action => "bet", :amount => bet)
      else
        self.action = "fold"
        self.in_round = false
        self.save
        fold_action_log
      end
    else
      self.action = "fold"
      self.in_round = false
      self.save
      fold_action_log
    end
  end
  
  def replace_cards(replace)      # ALL REPLACEMENT HAPPENS HERE
    if replace.to_i == 0
      PlayerActionLog.create(:hand_id => round.id,
                             :player_id => self.id,
                             :action => "replace",
                             :comment => "nothing")
      reset_after_replacement
    else
      replace = replace.split("")
      array_of_discards = []
      if acceptable_replacement?(replace)
        replace.each do |index|
          array_of_discards << self.hand[index.to_i-1]
        end
        PlayerActionLog.create(:hand_id => round.id,
                               :player_id => self.id,
                               :action => "replace",
                               :cards => array_of_discards.join(",").gsub(","," "))
        self.hand-=array_of_discards                          # Subtracts cards from hand
        logger.debug "#{self.name}'s hand: #{self.hand}"
        length = array_of_discards.length
        table = self.table 
        temp_hand = []
        while(length > 0)  
          temp_hand << table.deal                             # Deals appropriate number of cards to player
          table.save
          length-=1
        end
        self.hand+=temp_hand
        self.save
        PlayerActionLog.create(:hand_id => round.id,
                               :player_id => self.id,
                               :action => "receive",
                               :cards => temp_hand.join(",").gsub(","," "))
        reset_after_replacement                              # Sets action to nil, bet to 0, replacement to true
      else
        self.in_round = false
        self.save
      end
    end
  end
  
  def acceptable_replacement?(replace)      # REPLACEMENT VALIDATION HAPPENS HERE
    if replace.length == replace.uniq.length #&& replace.length <=5
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
  
  def change_hand_to_PokerHand
    self.hand = PokerHand.new(self.hand)
    self.save
  end
  
  def reset_after_replacement
    self.action = nil
    self.replacement = true
    self.bet = 0
    self.save
  end
   
  private 
  
  def fold_action_log
    PlayerActionLog.create(:hand_id => self.table.round.id, :player_id => self.id, :action => "fold") 
  end
  
end
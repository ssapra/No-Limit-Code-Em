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
                  :seat_id,
                  :losing_time
                  
  serialize :hand
  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 5, :maximum => 20 }
  validates :game_id, :presence => true, :uniqueness => true, :length => { :minimum => 5, :maximum => 20 }
  belongs_to :seat
  
  def table
    seat = Seat.find_by_id(self.seat_id)
    if seat
      Table.find_by_id(seat.table_id)
    else
      nil
    end
  end
  
  def round
    table.rounds.last                     # Shortcut for getting to current round
  end
  
  def resolve_action(action, parameter)   # ALL BETTING VALIDATION LOGIC IS HERE
    case action
      when "check"
        Action.check(self, action, parameter)
      when "bet"
        Action.bet(self, action, parameter)
      when "call"
        Action.call(self, action, parameter)
      when "raise"
        Action.raising(self, action, parameter)
      when "fold"
        Action.record_fold(self)
      else
        Action.record_raw_action(self, action, parameter)
        Action.record_fold(self)
    end
  end
  
  def replace_cards(replace, comment = nil)      # ALL REPLACEMENT HAPPENS HERE
    if replace.to_i == 0
      comment ||= "nothing"
      PlayerActionLog.create(:hand_id => round.id, :player_id => self.id, :action => "replace", :comment => comment)
      reset_after_replacement
    else
      if acceptable_replacement?(replace)
        discarded_cards = remove_cards(replace)
        num_of_replacements = discarded_cards.length
        replacement_cards = new_cards(num_of_replacements)
        self.hand += replacement_cards
        self.save
        PlayerActionLog.create(:hand_id => round.id, :player_id => self.id, :action => "receive", :cards => replacement_cards.join(",").gsub(","," "))
        reset_after_replacement
      else
        PlayerActionLog.create(:hand_id => round.id, :cards => replace, :action => "fold", :player_id => self.id, :comment => "Invalid Replacement")
        Action.record_fold(self)
      end
    end
  end
  
  def remove_cards(replace)
    array_of_discards = []
    replace.split("").each do |index|
      array_of_discards << self.hand[index.to_i-1]
    end
    PlayerActionLog.create(:hand_id => self.round.id, :player_id => self.id, :action => "replace", :cards => array_of_discards.join(",").gsub(","," "))
    self.hand-=array_of_discards
    self.save
    logger.debug "array of discards: #{array_of_discards}"
    return array_of_discards
  end
  
  def new_cards(amount_needed)
    temp_hand = []
    table = self.table
    amount_needed.times do
      table.reload
      temp_hand << table.deal
      table.save
    end
    # table.save
    return temp_hand
  end
  
  def acceptable_replacement?(replace)      # REPLACEMENT VALIDATION HAPPENS HERE
    replace = replace.split("")
    logger.debug "replace: #{replace}"
    if replace.length == replace.uniq.length && replace.length <= 3
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
  
  def bettingid_check
    if self.table.round.second_bet
      return 2
    else
      return 1
    end
  end
  
  def remove_from_pot
    for pot in self.round.pots
      pot.reload
      pot.player_ids.delete(self.id)
      pot.save
    end
  end
  
end
  

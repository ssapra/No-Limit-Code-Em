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
    min_bet = round.minimum_bet
    if action == 'check'
      if min_bet == self.bet
        save_player_action("check", 0, 0, 0)
        player_action_log("check", nil, nil)
      else
        raw_action_log(action, parameter)
        fold_action_log
      end
    elsif action == 'bet'
      bet = parameter.to_i
      if min_bet == self.bet && bet <= self.stack && bet <= smallest_stack
        save_player_action("bet", bet, bet, bet)
        if self.stack == 0
          player_action_log("bet", bet, "ALL IN")
        else
          player_action_log("bet", bet, nil)
        end  
      elsif min_bet == self.bet && bet <= self.stack && bet > smallest_stack
        raw_action_log(action, parameter)
        bet = smallest_stack
        save_player_action("bet", bet, bet, bet)
        if self.stack == 0
          player_action_log("bet", bet, "ALL IN")
        else
          player_action_log("bet", bet, nil)
        end
      else          
        raw_action_log(action, parameter)
        fold_action_log
      end
    elsif action == 'call'
      bet = min_bet - self.bet
      if bet <= self.stack  
        save_player_action("call", bet, bet, bet)
        if self.stack == 0
          player_action_log("call", bet, "ALL IN")
        else
          player_action_log("bet", bet, nil)
        end
      else
        raw_action_log(action, parameter)
        fold_action_log
      end
    elsif action == 'raise'
      bet = parameter.to_i
      # probably should have some validation that bet is not a string in the first place
      true_bet = bet + min_bet - self.bet
      if min_bet != self.bet && true_bet <= self.stack && bet > 0 && bet <= smallest_stack
        save_player_action("raise", true_bet, true_bet, true_bet)
        if self.stack == 0
          player_action_log("raise", bet, "ALL IN")
        else
          player_action_log("raise", bet, nil)
        end
      elsif min_bet != self.bet && true_bet <= self.stack && bet > 0 && bet > smallest_stack
        raw_action_log(action, parameter)
        bet = min_bet - smallest_stack
        save_player_action("raise", bet - self.bet, bet + self.bet, bet + min_bet - self.bet)
        if self.stack == 0
          player_action_log("raise", bet, "ALL IN")
        else
          player_action_log("raise", bet, nil)
        end
      else
        raw_action_log(action, parameter)
        fold_action_log
      end
    elsif action == "fold"
      fold_action_log
    else
      raw_action_log(action, parameter)
      fold_action_log
    end
  end
  
  def save_player_action(action, stack_change, pot_change, bet_change)
    pot = self.round.pot
    self.action = action
    self.stack -= stack_change
    pot.total += pot_change
    self.bet += bet_change
    self.save
    pot.save
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
    if replace.length == replace.uniq.length && replace.length <=3
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
  
  def smallest_stack
    smallest_stack = 10000
    self.table.round.players_in.each do |player|
      if player.stack <= smallest_stack && player.stack != 0
        smallest_stack = player.stack
      end
    end
    return smallest_stack
  end
   
  private 
  
  def raw_action_log(raw_action, raw_parameter)
    PlayerActionLog.create(:hand_id => self.table.round.id,
                           :betting_round_id => self.bettingid_check, 
                           :player_id => self.id, 
                           :action => raw_action, 
                           :amount => raw_parameter,
                           :comment => "Invalid Action")
  end
  
  def player_action_log(action, bet, comment)
    PlayerActionLog.create(:hand_id => round.id, :betting_round_id => self.bettingid_check, :player_id => self.id, :action => action, :amount => bet, :comment => comment)
  end
  
  def fold_action_log
    self.action = "fold"
    self.in_round = false
    self.save
    PlayerActionLog.create(:hand_id => self.table.round.id, :betting_round_id => self.bettingid_check, :player_id => self.id, :action => "fold") 
  end
  
end
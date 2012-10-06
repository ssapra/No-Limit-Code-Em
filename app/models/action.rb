class Action < ActiveRecord::Base
  
  def self.check(player, action, parameter)
    if player.round.minimum_bet == player.bet
      Action.save_player_action(player, "check", 0)
    else
      Action.record_raw_action(player, action, parameter)
      Action.record_fold(player)
    end
  end
  
  def self.bet(player, action, parameter)
    bet = parameter.to_i
    round = player.round
    min_bet = round.minimum_bet
    minimum_stack = round.smallest_stack
    if bet == 0
      Action.save_player_action(player, "check", 0)
    elsif min_bet == player.bet && bet <= player.stack && bet <= minimum_stack
      Action.save_player_action(player, "bet", bet)
    elsif min_bet == player.bet && bet <= player.stack && bet > minimum_stack
      Action.record_raw_action(player, action, parameter)
      bet = minimum_stack
      Action.save_player_action(player, "bet", bet)
    else          
      Action.record_raw_action(player, action, parameter)
      Action.record_fold(player)
    end
  end
  
  def self.call(player, action, paramter)
    min_bet = player.round.minimum_bet
    bet = min_bet - player.bet
    if bet <= player.stack  
      Action.save_player_action(player, "call", bet)
    else
      Action.record_raw_action(player, action, parameter)
      Action.record_fold(player)
    end
  end
  
  def self.raising(player, action, parameter)
    raise_amount = parameter.to_i
    round = player.round
    min_bet = round.minimum_bet
    minimum_stack = round.smallest_stack
    call_amount = min_bet - player.bet
    total_bet = raise_amount + call_amount
    if min_bet != player.bet && total_bet <= player.stack && raise_amount > 0 && raise_amount <= minimum_stack
      Action.save_player_action(player, "call", call_amount)
      Action.save_player_action(player, "raise", raise_amount)
      #Action.save_player_action(player, "raise", total_bet)
    elsif min_bet != player.bet && total_bet <= player.stack && raise_amount > 0 && raise_amount > minimum_stack
      smallest_raise = player.smallest_stack
      Action.record_raw_action(action, parameter)
      Action.save_player_action(player, "call", call_amount)
      Action.save_player_action(player, "raise", smallest_raise)
      #Action.save_player_action(player, "raise", smallest_raise + call_amount)
    else
      Action.record_raw_action(player, action, parameter)
      Action.record_fold(player)
    end
  end
  
  def self.save_player_action(player, action, amount)
    pot = player.round.pot
    player.action = action
    player.stack -= amount
    pot.total += amount
    player.bet += amount
    player.save
    pot.save
    Action.record_valid_action(player, action, amount)
  end
  
  def self.record_valid_action(player, action, parameter)
    player.reload
    if player.stack == 0 then comment = "ALL IN" else comment = nil end
    if parameter == 0 then parameter = nil end
    PlayerActionLog.create(:hand_id => player.round.id, :betting_round_id => player.bettingid_check, :player_id => player.id, :action => action, :amount => parameter, :comment => comment)
  end
  
  def self.record_raw_action(player, raw_action, raw_parameter)
    PlayerActionLog.create(:hand_id => player.round.id, :betting_round_id => player.bettingid_check, :player_id => player.id, :action => raw_action, :amount => raw_parameter, :comment => "Invalid Action")
  end
  
  def self.record_fold(player, comment = nil)
    player.action = "fold"
    player.in_round = false
    player.save
    player.remove_from_pot
    PlayerActionLog.create(:hand_id => player.round.id, :betting_round_id => player.bettingid_check, :player_id => player.id, :action => "fold", :comment => comment) 
  end
  
end

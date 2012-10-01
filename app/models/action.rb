class Action < ActiveRecord::Base
  
  def self.check(player, action, parameter)
    if player.round.minimum_bet == player.bet
      Action.save_player_action(player, "check", nil)
    else
      Action.record_raw_action(player, action, parameter)
      Action.record_fold(player)
    end
  end
  
  def self.bet(player, action, parameter)
    bet = parameter.to_i
    min_bet = player.round.minimum_bet
    minimum_stack = player.smallest_stack
    if min_bet == player.bet && bet <= player.stack && bet <= minimum_stack
      Action.save_player_action(player, "bet", bet)
    elsif min_bet == player.bet && bet <= player.stack && bet > minimum_stack
      Action.record_raw_action(player, action, parameter)
      bet = player.smallest_stack
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
      Action.save_player_action(player, "bet", bet)
    else
      Action.record_raw_action(player, action, parameter)
      Action.record_fold(player)
    end
  end
  
  def self.raising(player, action, parameter)
    bet = parameter.to_i
    min_bet = player.round.minimum_bet
    minimum_stack = player.smallest_stack
    # probably should have some validation that bet is not a string in the first place
    true_bet = bet + min_bet - player.bet
    if min_bet != player.bet && true_bet <= player.stack && bet > 0 && bet <= minimum_stack
      Action.save_player_action(player, "raise", true_bet)
    elsif min_bet != player.bet && true_bet <= player.stack && bet > 0 && bet > minimum_stack
      bet = player.smallest_stack
      Action.record_raw_action(action, parameter)
      Action.save_player_action(player, "raise", bet + min_bet - player.bet)
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
    PlayerActionLog.create(:hand_id => player.round.id, :betting_round_id => player.bettingid_check, :player_id => player.id, :action => action, :amount => parameter, :comment => comment)
  end
  
  def self.record_raw_action(player, raw_action, raw_parameter)
    PlayerActionLog.create(:hand_id => player.round.id, :betting_round_id => player.bettingid_check, :player_id => player.id, :action => raw_action, :amount => raw_parameter, :comment => "Invalid Action")
  end
  
  def self.record_fold(player)
    player.action = "fold"
    player.in_round = false
    player.save
    player.remove_from_pot
    PlayerActionLog.create(:hand_id => player.round.id, :betting_round_id => player.bettingid_check, :player_id => player.id, :action => "fold") 
  end
  
end
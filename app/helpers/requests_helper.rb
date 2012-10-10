module RequestsHelper
  
  
  def betting_summary(round)
    if round.second_bet then br_id = 2 else br_id = 1 end
    # actions = PlayerActionLog.find_all_by_betting_round_id_and_hand_id_and_action(br_id, round.id, ["check","bet","fold"])
    actions = PlayerActionLog.find_all_by_betting_round_id_and_hand_id(br_id, round.id)
  
    betting_summary = actions.map do |action|
      player_name = Player.find_by_id(action.player_id).name 
      if action.comment
        "#{player_name} #{action.action.pluralize} #{action.amount} -- #{action.comment}"
      else
        "#{player_name} #{action.action.pluralize} #{action.amount}"
      end
    end
    return betting_summary
  end
  
  def replacement_summary(round)
    replacements = PlayerActionLog.find_all_by_hand_id_and_action(round.id, "replace")
    replacement_summary = replacements.map do |action| 
      player_name = Player.find_by_id(action.player_id).name
      if action.cards then num_replaced = action.cards.split(" ").length else num_replaced = 0 end
      "#{player_name} replaced #{num_replaced} cards"
    end
    return replacement_summary
  end
  
  def round_summary(table, round)
    logs = HandLog.find_all_by_table_id(table.id)
    if (logs.length > 1 && round.second_bet == false) || table.waiting || Table.all.count == 1
      if table.waiting || table.game_over
        if logs[logs.length - 2] then previous_round_id = logs[logs.length - 2].hand_id end
        if logs.last then round_id = logs.last.hand_id end
      else
        if logs.length > 2 then previous_round_id = logs[logs.length - 3].hand_id end
        if logs[logs.length - 2] then round_id = logs[logs.length - 2].hand_id end
      end
      if round_id then last_round = capture_round_summary_data(round_id) end
      if previous_round_id then previous_round = capture_round_summary_data(previous_round_id) end
      if previous_round then return [previous_round, last_round] else return last_round end
    end
  end
  
  def player_standings
    players = Player.all.sort!{|a,b| b.losing_time <=> a.losing_time}
    index = 0
    summary = players.map do |player|
      index+=1
      "#{index}: #{player.name}"
    end
    summary.unshift("Tournament is Over.", " ", "Player Standings", "----------------")
    return summary
  end
  
  def capture_round_summary_data(round_id)
    winning_action = PlayerActionLog.find_all_by_hand_id_and_action(round_id, ["win","lost"])
    round_summary = winning_action.map do |action|
      player_name = Player.find_by_id(action.player_id).name
      if action.action == "win"
        "#{player_name} won #{action.amount} chips#{action.comment} for Hand ##{action.hand_id}"
      else
        "#{player_name} lost -- #{action.comment}"
      end
    end
    return round_summary
  end
  
  def players_last_summary(player_id)
    winning_action = PlayerActionLog.find_all_by_player_id_and_action(player_id, ["win","lost"])
    previous_winner = winning_action.map do |action|  
        player_name = Player.find_by_id(action.player_id).name
        if action.action == "win"
          "#{player_name} won #{action.amount} chips #{action.comment} for Hand ##{action.hand_id}"
        else
          "#{player_name} lost -- #{action.comment}"
        end
      end
    return previous_winner
  end
  
  
end
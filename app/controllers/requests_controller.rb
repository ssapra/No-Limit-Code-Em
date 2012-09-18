class RequestsController < ApplicationController
  require 'digest/md5'
  require 'net/http'
  
  def display
    @players = Player.all
  end
  
  def registration
    player = Player.new(:name => params["name"], :game_id => params["game_id"], :player_key => params["player_key"])
   
    body = respond_to_request(player)
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.js
    end
  end
  
  def state
    if Status.first.game
      player = Player.find_by_name(params[:name])
      if player && verify_player_turn?(player)
        table = player.table
        round = table.round
        body = {:message => "It's your turn", 
                :hand => player.hand, 
                :bet => player.bet, 
                :min_bet => round.minimum_bet, 
                :stack => player.stack, 
                :pot => round.pot, 
                :play => true, 
                :replacement => player.replacement,
                :table_id => table.id}
       
        if round.second_bet then br_id = 2 else br_id = 1 end
        actions = PlayerActionLog.find_all_by_betting_round_id_and_hand_id_and_action(br_id, round.id, ["check","bet","fold"])
        body[:betting_summary] = actions.map do |action|
          player = Player.find_by_id(action.player_id).name 
          "#{player} #{action.action.pluralize} #{action.amount}"
        end
        
        
        replacements = PlayerActionLog.find_all_by_hand_id_and_action(round.id, "replace")
        body[:replacement_summary] = replacements.map do |action| 
          player = Player.find_by_id(action.player_id).name
          if action.cards then num_replaced = action.cards.split(" ").length else num_replaced = 0 end
          "#{player} replaced #{num_replaced} cards"
        end
        
        
        logs = HandLog.find_all_by_table_id(table.id)
        if logs.length > 1 && round.second_bet == false
          round_id = logs[logs.length - 2].hand_id
          winning_action = PlayerActionLog.find_all_by_hand_id_and_action(round_id, "win")
          body[:previous_winner] = winning_action.map do |action|
            player = Player.find_by_id(action.player_id).name
            "#{player} won #{action.amount} chips #{action.comment}"
          end
        end
        
        
      else 
        body = {:message => "It's NOT your turn", 
                :play => false}
      end
    else
      body = {:message => "Game hasn't started yet."}
    end
  
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.js
    end
  end
  
end

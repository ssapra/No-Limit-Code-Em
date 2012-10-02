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
      format.xml {render :xml => body, :status => 200}
      format.js
    end
  end
  
  def state
    if Status.first.game
      player = Player.find_by_name(params[:name]) 
      if player                                     # Added security for this part
        table = player.table
        body = {}
        if table != nil
          
          round = table.round
          
          if table.turn_id 
            current_player = Player.find_by_id(table.turn_id)
            body.merge!({:current_player => current_player.name, :replacement => current_player.replacement})
          end
          
          smallest_stack = round.smallest_stack
          
          body.merge!({:hand => player.hand, 
                     :bet => player.bet, 
                     :min_bet => round.minimum_bet,
                     :max_bet => smallest_stack,
                     :max_raise => [player.stack - (round.minimum_bet - player.bet), smallest_stack].min,
                     :stack => player.stack, 
                     :pot => round.total_pot, 
                     :table_id => table.id})
                     
                     
       
          if round.second_bet then br_id = 2 else br_id = 1 end
          # actions = PlayerActionLog.find_all_by_betting_round_id_and_hand_id_and_action(br_id, round.id, ["check","bet","fold"])
          actions = PlayerActionLog.find_all_by_betting_round_id_and_hand_id(br_id, round.id)
        
          body[:betting_summary] = actions.map do |action|
            player_name = Player.find_by_id(action.player_id).name 
            if action.comment
              "#{player_name} #{action.action.pluralize} #{action.amount} -- #{action.comment}"
            else
              "#{player_name} #{action.action.pluralize} #{action.amount}"
            end
          end
        
        
        
          replacements = PlayerActionLog.find_all_by_hand_id_and_action(round.id, "replace")
          body[:replacement_summary] = replacements.map do |action| 
            player_name = Player.find_by_id(action.player_id).name
            if action.cards then num_replaced = action.cards.split(" ").length else num_replaced = 0 end
            "#{player_name} replaced #{num_replaced} cards"
          end
        
        
        
          logs = HandLog.find_all_by_table_id(table.id)
          if logs.length > 1 && round.second_bet == false || table.waiting
            if table.waiting
              round_id = logs.last.hand_id
            else
              round_id = logs[logs.length - 2].hand_id
            end
            winning_action = PlayerActionLog.find_all_by_hand_id_and_action(round_id, ["win","lost"])
            body[:round_summary] = winning_action.map do |action|
              player_name = Player.find_by_id(action.player_id).name
              if action.action == "win"
                "#{player_name} won #{action.amount} chips #{action.comment} for Hand ##{action.hand_id}"
              else
                "#{player_name} lost"
              end
            end
          end
          
        
          if verify_player_turn?(player)
            body[:play] = true
          else 
            body[:play] = false
          end
          
          if table.waiting
            body[:waiting => true]
            body[:message => "Tables are about to reshuffle..."]
          end
          
          logger.debug "Body : #{body.inspect}"  
        else
           first = PlayerActionLog.find_by_comment("First")
           if first
             players = Player.all.sort!{|a,b| b.losing_time <=> a.losing_time}
             index = 0
             summary = players.map do |player|
               index+=1
               "#{index}: #{player.name}"
             end
             summary.unshift("Tournament is Over.", " ", "Player Standings", "----------------") 
        
             round_id = HandLog.last.hand_id
             winning_action = PlayerActionLog.find_all_by_hand_id_and_action(round_id, ["win","lost"])
             previous_winner = winning_action.map do |action|
               player_name = Player.find_by_id(action.player_id).name
               if action.action == "win"
                 "#{player_name} won #{action.amount} chips #{action.comment} for Hand ##{action.hand_id}"
               else
                 "#{player_name} lost"
               end
             end
          
             
             body = {:message => "Tournament is Over", :winning_summary => summary, :round_summary => previous_winner, :game_over => true}
           else
             winning_action = PlayerActionLog.find_all_by_player_id_and_action(player.id, ["win","lost"]) # How to stop this from happening each time they ping me?
             previous_winner = winning_action.map do |action|
               player_name = Player.find_by_id(action.player_id).name
               if action.action == "win"
                 "#{player_name} won #{action.amount} chips #{action.comment} for Hand ##{action.hand_id}"
               else
                 "#{player_name} lost"
               end
             end
             body = {:message => "You're out", :round_summary => previous_winner}
           end
        end
      end
    else
      body = {:message => "Game hasn't started yet"}
    end
  
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.xml  {render :xml => body, :status => 200}
      format.js
    end
  end
  
  def player_turn
    player = Player.find_by_name(params[:name])

    if player && verify_player_turn?(player) 
      if player.replacement == false
        logger.debug "RECEIVED PLAYER ACTION"
        player.resolve_action(params[:player_action], params[:parameters])
        player.round.next_action
      elsif player.replacement && params[:player_action] == "replacement" 
        logger.debug "REPLACEMENT RECEIVED"
        player.replace_cards(params[:parameters]) 
        player.round.next_replacement
      end
    end
      
    respond_to do |format|
      format.html {redirect_to display_path}
    end
  end
  
end

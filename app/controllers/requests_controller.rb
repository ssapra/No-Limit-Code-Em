class RequestsController < ApplicationController
  require 'digest/md5'
  require 'net/http'
  include RequestsHelper
  
  def display
    @players = Player.all
  end
  
  def new_player
    @player = Player.new
  end
  
  def registration
    logger.debug "received parameters"
    if params[:player]
      body = respond_to_request(params[:player][:name], params[:player][:game_id])
    else
      body = respond_to_request(params[:name], params[:game_id])
    end
    message = "#{body[:message]}"
    if body[:player_key] then message += " Your player key is #{body[:player_key]}" end
    flash[:notice] = message
    logger.debug "body: #{body}"
    respond_to do |format|
      format.json {render :json => body, :status => 200}
      format.html {redirect_to root_path}
      format.xml {render :xml => body, :status => 200}
    end
  end
  
  def state
    if Status.first.game
      player = Player.find_by_name(params[:name]) 
      if player && verify_player?(player, params[:player_key])                               
        table = player.table
        body = {}
        if table != nil && table.game_over != true # TABLE IS STILL ALIVE OR TABLE IS WAIITNG TO RESHUFFLE
          
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
                     
          body[:betting_summary] = betting_summary(round)
          body[:replacement_summary] = replacement_summary(round)        
          body[:round_summary] = round_summary(table, round)
          body[:play] = verify_player_turn?(player)
          body.merge!({:waiting => true, :message => "Tables are about to reshuffle..."}) if table.waiting
          logger.debug "Body : #{body.inspect}"  
        else # TABLE DOESN'T EXIST MEANS 1. YOUR OUT, BUT TOURNAMENT IS STILL GOING OR 2. TOURNAMENT IS OVER
           first = PlayerActionLog.find_by_comment("First")
           if first # TOURNAMENT IS OVER
             summary = player_standings
             table = Table.first
             previous_winner = round_summary(table, table.round)
             body = {:message => "Tournament is Over", :winning_summary => summary, :round_summary => previous_winner, :game_over => true}
             logger.debug "Body : #{body.inspect}"  
           else # TOURNAMENT IS STILL GOING
             previous_winner = players_last_summary(player.id)
             body = {:message => "You're out", :round_summary => previous_winner}
             logger.debug "Body : #{body.inspect}"  
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

    if player && verify_player?(player, params[:player_key]) && verify_player_turn?(player) 
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

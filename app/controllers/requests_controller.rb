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
      else 
        logger.debug "Table get request: #{player.table.inspect}"
        # current_player = Player.find_by_id(player.table.turn_id)
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

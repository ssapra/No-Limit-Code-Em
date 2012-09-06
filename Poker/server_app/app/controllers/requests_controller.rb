class RequestsController < ApplicationController
  require 'digest/md5'
  require 'net/http'
  
  def display
    @players = Player.all
  end
  
  def post
    player = Player.new(:name => params["name"], :game_id => params["game_id"], :player_key => params["player_key"])
   
    body = respond_to_request(player)
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.js
    end
  end
  
  def states
    if Status.first.play
      player = Player.find_by_name(params[:name])
      if player && verify_player_turn?(player)
        table = player.table
        body = {:message => "It's your turn", :hand => player.hand, :bet => player.bet, :stack => player.stack, :pot => table.pot, :play => true, :replacement => player.replacement}
      else 
        body = {:message => "It's NOT your turn", :play => false}
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

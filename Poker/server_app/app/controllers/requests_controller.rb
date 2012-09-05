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
    
    player = Player.find_by_name(params[:name])
    if player && verify_player_turn?(player)
      body = {:message => "It's your turn"}
    else 
      body = {:message => "It's NOT your turn", :hand => player.hand}
    end
  
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.js
    end
  end
  
end

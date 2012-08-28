class RequestsController < ApplicationController
  require 'digest/md5'
  
  
  def display
    @inputs = Input.all
  end
  
  def post
    require 'net/http'
    
    player = Player.new(:name => params["name"], :game_id => params["game_id"], :player_key => params["player_key"])
   
   
    if player.player_key
      temp_player = Player.find_by_name(player.name)
      if Digest::MD5.hexdigest("#{temp_player.name} #{temp_player.game_id} TREY") == player.player_key
        body = {:message => "You have already registered. Registration is currently open."}
      else 
        body = {:message => "Invalid inputs"}
      end
    else  
        if player.valid? && player.game_id == 4
          player.player_key = Digest::MD5.hexdigest("#{player.name} #{player.game_id} TREY")
          player.save
          Input.create(:data => params["name"]) 
          body = {:message => "ok", :player_key => player.player_key, :player_name => player.name, :game_id => player.game_id}
        else
          body = {:message => "Invalid inputs"}
        end
    end
    
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.js
    end
    
  end
  
end

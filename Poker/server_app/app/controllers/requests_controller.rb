class RequestsController < ApplicationController
  require 'digest/md5'
  
  
  def display
    @players = Player.all
  end
  
  def post
    require 'net/http'
    
    player = Player.new(:name => params["name"], :game_id => params["game_id"], :player_key => params["player_key"])
   
    
    if player.player_key
      temp_player = Player.find_by_name(player.name)
      if Digest::MD5.hexdigest("#{temp_player.name} #{temp_player.game_id} TREY") == player.player_key
        if Status.first.registration
          body = {:message => "You have already registered. Registration is closed. Waiting for game to begin."}
        elsif Status.first.game && !Status.first.play
          body = {:message => "The game is being created. Waiting for play to begin."}
        elsif Status.first.game && Status.first.play
          body = {:message => "It might be your turn. We're still working on it."}
        else
          body = {:message => "You have already registered. Registration is still open."}
        end
      else 
        body = {:message => "Invalid inputs"}
      end
    else
        if Status.first.registration
          if player.valid? && player.game_id == 4
            player.player_key = Digest::MD5.hexdigest("#{player.name} #{player.game_id} TREY")
            player.save
            #Input.create(:data => params["name"]) 
            body = {:message => "ok", :player_key => player.player_key, :player_name => player.name, :game_id => player.game_id}
          else
            body = {:message => "Invalid inputs"}
          end
        else
          body = {:message => "Sorry, registration has closed"}
        end
    end
    
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.js
    end
    
  end
  
end

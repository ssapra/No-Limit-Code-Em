class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :respond_to_request,
                :verify_player_turn?,
                :minimum_bet,
                :players_ready?
            
  protected
  
  def verify_player_turn?(player)
     #if Digest::MD5.hexdigest("#{temp_player.name} #{temp_player.game_id} TREY") == player.player_key
      begin 
         table = player.table
         if table.turn_id == player.id
           return true
         end
         return false
      rescue
         return false
      end
  end
      
  
  def respond_to_request(player)
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
          body = {:message => "Registration is closed. Waiting for game to begin."}
        end
      else 
        body = {:message => "Invalid inputs"}
      end
    else
        if Status.first.registration
          if player.valid? && player.game_id == 4
            player.player_key = Digest::MD5.hexdigest("#{player.name} #{player.game_id} TREY")
            player.save
            body = {:message => "ok", :player_key => player.player_key, :player_name => player.name, :game_id => player.game_id}
          else
            body = {:message => "Invalid inputs"}
          end
        else
          body = {:message => "Sorry, registration has closed"}
        end
    end
    return body
  end
  
end

module PlayersHelper
  
  def verify_player_turn?(player)
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
  
  def verify_player?(player, player_key)
    player_key == player.player_key    
  end
  
end
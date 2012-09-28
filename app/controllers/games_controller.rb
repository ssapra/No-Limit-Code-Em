class GamesController < ApplicationController
  include RubyPoker
  
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
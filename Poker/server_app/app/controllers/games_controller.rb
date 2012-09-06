class GamesController < ApplicationController
  include RubyPoker
  
  def action
    player = Player.find_by_name(params[:name])

    if player && verify_player_turn?(player) && params[:player_action]
      player.resolve_action(params[:player_action])
      player.table.next_action
    end
    
    if player && verify_player_turn?(player) && params[:replacement]
      if params[:replacement].to_i != 0 then player.replace_cards(params[:replacement]) end 
      player.table.next_replacment
    end
      
    respond_to do |format|
      format.html {redirect_to display_path}
    end
  end
  
end
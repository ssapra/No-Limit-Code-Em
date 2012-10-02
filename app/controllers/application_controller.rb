class ApplicationController < ActionController::Base
  protect_from_forgery
  include RubyPoker
  include ApplicationHelper
  # include TableManager
  # require 'table_manager.rb'
  helper_method :respond_to_request,
                :verify_player_turn?,
                :setup_tables,
                :empty_seats
  protected
  
  def empty_seats
    count = 0
    Table.all.each do |table|
      table.players.each do |player|
        if player.in_game == false
          count+=1
        end
      end
    end
    return count
  end
  
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
        elsif Status.first.game
          body = {:message => "It might be your turn."}
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
  
  # def setup_tables
  #     logger.debug "REACHED TABLES"
  #     Table.destroy_all
  #     player_ids = Player.all.map {|player| player.id if player.in_game}
  #     logger.debug "ids: #{player_ids}"
  #     table_list = TableManager.assign(player_ids, ServerApp::Application.config.MAX_TABLE_SIZE)
  #     logger.debug "#{table_list}"
  #     table_list.each do |players|
  #       table = Table.create(:deck => Deck.new)
  #       players.each do |id|
  #         seat = Seat.create(:table_id => table.id, :player_id => id)
  #         Player.find_by_id(id).update_attributes(:seat_id => seat.id, :hand => [], :replacement => false)
  #       end
  #     end
  #   end
  
end

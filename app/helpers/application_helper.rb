module ApplicationHelper
  
  include RubyPoker
  
  def setup_tables
    logger.debug "REACHED TABLES"
    Table.destroy_all
    player_ids = Player.all.map do |player| 
      player.reload
      if player.in_game then player.id end
    end
    logger.debug "ids: #{player_ids}"    
    player_ids-=[nil]
    logger.debug "ids: #{player_ids}"
    table_list = TableManager.assign(player_ids, ServerApp::Application.config.MAX_TABLE_SIZE)
    logger.debug "#{table_list}"
    table_list.each do |player_ids|
      table = Table.create(:deck => Deck.new, :waiting => false)
      player_ids.each do |id|
        seat = Seat.create(:table_id => table.id, :player_id => id)
        Player.find_by_id(id).update_attributes(:seat_id => seat.id, :hand => [], :replacement => false)
      end
    end
  end
  
end

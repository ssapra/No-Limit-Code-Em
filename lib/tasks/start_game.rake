include RubyPoker

desc "Starts the poker game"
task :start_game => :environment do
  start_game_thread = Thread.new do
    # logger.info "\nStarting timeout bot."
    start_game!
    # logger.info "\nTimeout bot spinning down."
  end
  start_game_thread.join
end


def start_game!
  PlayerActionLog.destroy_all
  HandLog.destroy_all
  PlayerStateLog.destroy_all
  Status.first.update_attributes(:waiting => false)
  if Player.all.count > 1
   setup_tables
   Table.all.each do |table|
     table.begin_play
   end
   status.game = true
   status.save!
   Rake::Task["timeout_bot"].invoke
  end
end

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

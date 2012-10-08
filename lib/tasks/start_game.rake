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

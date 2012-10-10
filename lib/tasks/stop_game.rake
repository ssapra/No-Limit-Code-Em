desc "Stops the poker game"
task :stop_game => :environment do
  stop_game_thread = Thread.new do
    puts "\nStarting stop game task."
    stop_game!
    puts "\nFinished stop game bot."
  end
  stop_game_thread.join
end

def stop_game!
  status = Status.first
  status.game = false
  status.save
end

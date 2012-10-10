desc "Starts Game Registration"
task :start_registration => :environment do
  start_registration_thread = Thread.new do
    puts "\nStarting registration task."
    start_registration!
    puts "\nFinished starting registration."
  end
  stop_game_thread.join
end

def start_registration!
  status = Status.first
  status.registration = true
  Player.destroy_all
  status.save!
end

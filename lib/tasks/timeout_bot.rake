require 'net/http'
require 'json'
desc "Runs timeout bot"
task :timeout_bot do
  timeout_bot_thread = Thread.new do
    logger.debug "\nStarting timeout bot."
    run_timeout_bot!
    logger.debug "\nTimeout bot spinning down."
  end
  timeout_bot_thread.join
end

def run_timeout_bot!
  15.times do
    sleep 6
    logger.debug "Timing out users"
  end
end

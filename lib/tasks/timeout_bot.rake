desc "Runs timeout bot"
task :timeout_bot => :environment do
  timeout_bot_thread = Thread.new do
    # logger.info "\nStarting timeout bot."
    run_timeout_bot!
    # logger.info "\nTimeout bot spinning down."
  end
  timeout_bot_thread.join
end

def run_timeout_bot!
  sleep 6
  while Status.first.game do
    Table.all.each do |active_table|
      next unless active_table.turn_id
      puts "  Table #{ active_table.id }"
      next unless current_hand_log = HandLog.find_all_by_table_id(active_table.id).last
      # puts "    Hand Log: #{ current_hand_log.inspect }"
      hand_id = current_hand_log.hand_id
      next unless last_play = PlayerActionLog.find_all_by_hand_id(hand_id).select { |play| play.comment != "Invalid Action" }.last
      # puts "    Last Play: #{ last_play.inspect }"
      last_play_time = last_play.created_at
      if Time.now - last_play_time > 6 # covers race condition
        next unless current_player = Player.find_by_id(active_table.turn_id)
        puts "    FORCE FOLD FOR PLAYER #{ current_player.id }"
        Action.record_fold(current_player, "fold_by_timeout_bot")
        current_player.round.next_action
      else
        # puts "    no folds"
      end
    end
    puts "#{ Time.now } Timing out users"
    sleep 6
  end
  puts "*** NO MORE TABLES, ENDING"
end

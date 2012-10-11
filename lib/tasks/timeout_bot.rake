desc "Runs timeout bot"
task :timeout_bot => :environment do
  run_timeout_bot!
end

def run_timeout_bot!
  start_time = Time.now
  while Status.first.game do
    Table.order(:id).all.each do |active_table|
      begin
        active_table.reload
        next unless active_table.turn_id
        puts "  Table #{ active_table.id }"
        next unless current_hand_log = HandLog.find(:last, :conditions => ["table_id = ?", active_table.id])
        # puts "    Hand Log: #{ current_hand_log.inspect }"
        hand_id = current_hand_log.hand_id
        active_table.reload # stupid, but at this point, i just want to cry
        next unless last_play = PlayerActionLog.find(:last, :conditions => ["hand_id = ? and (comment is null or comment not like ?)", hand_id, "Invalid Action%"])
        # puts "    Last Play: #{ last_play.inspect }"
        last_play_time = last_play.created_at
        if Time.now - last_play_time > 6 # covers race condition
          active_table.reload
          next unless current_player = Player.find_by_id(active_table.turn_id)
          puts "    found player #{ current_player.id }"
          next unless current_player.in_round
          puts "    FORCE FOLD FOR PLAYER #{ current_player.id }"
          if current_player.replacement
            current_player.replace_cards("0", "noop__by_timeout_bot")
            current_player.round.next_replacement
          else
            Action.record_fold(current_player, "fold_by_timeout_bot #{ last_play_time } #{ Time.now - last_play_time }")
            current_player.round.next_action
          end
        else
          puts "    no folds"
        end
      rescue
        puts "Table destroyed, not timing out"
      end
    end
    puts "#{ Time.now } Timing out users"
  end
  puts "*** NO MORE TABLES, ENDING"
end

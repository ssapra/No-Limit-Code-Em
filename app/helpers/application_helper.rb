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

  def stack_display(chips, border=true)
    colors = {:white=>1, :red=>5, :green=>25, :black=>100, :purple=>500, :yellow=>1000, :gray=>5000}

    chip_types = colors.to_a.sort_by{|c|c.last}.reverse.reduce([]) do |list, (color, value)|
      list += [color.to_s] * (chips / value)
      chips = chips % value
      list
    end.uniq

    chip_types.map { |color|
      "<i class='chip chip-#{color} #{"chip-bordered" if border}'></i>".html_safe
    }.join
  end

end

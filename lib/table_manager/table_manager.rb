module TableManager

  def self.assign(players, table_size)
    raise Exception, "table_size too small" if table_size <= 1
    if players.count == 0 
      return []
    elsif players.count <= table_size
      return [players]
    else
      $player_count = players.count 
      num_of_tables = ($player_count.to_f / table_size).ceil
      big_tables, players = TableManager.create_big_tables(players, num_of_tables)
      small_tables = TableManager.create_small_tables(players, num_of_tables)
      tables_of_players = big_tables + small_tables
      return tables_of_players
    end
  end

  def self.create_big_tables(players, num_of_tables)
     tables = []
     big_tables = $player_count % num_of_tables
     big_table_size = ($player_count.to_f/ num_of_tables).ceil
     big_tables.times do
       tables << players.shift(big_table_size)
     end
     return tables, players
  end

  def self.create_small_tables(players, num_of_tables)
    # return players
    tables = []
    small_tables = num_of_tables - $player_count % num_of_tables
    small_table_size = ($player_count.to_f/ num_of_tables).floor
    small_tables.times do
      tables << players.shift(small_table_size)
    end
    return tables
  end
end
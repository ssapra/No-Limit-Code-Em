require '/Users/nshah/Documents/Projects/No-Limit-Code-Em/spec/spec_helper.rb'

describe 'Split Pot' do

  it 'should split the pot and consider both the players as winners for equal hands' do
    player_ids = setup_player
    tables = setup_tables_for_test(player_ids)
    tables.each do |t|
      t.begin_play
      setup_hands(t.player_ids)
      pot = t.round.determine_winner
      pot.first.player_ids.should == t.player_ids
      t.players.first.stack.should == t.players.second.stack
    end
  end
end

def setup_player(no_of_players = 2)
  players = []
  no_of_players.times do |a|
    Player.find_by_name("#{a}0001") && Player.find_by_name("#{a}0001").destroy
    Player.find_by_game_id("#{a}0001") && Player.find_by_game_id("#{a}0001").destroy
    p = Player.new(:name => "#{a}0001", :game_id => "#{a}0001")
    p.save
    players << p
  end
  players.collect do |a| a.id end
end

def setup_tables_for_test(player_ids)
  Table.destroy_all
  player_ids-=[nil]
  tables = []
  table_list = TableManager.assign(player_ids, ServerApp::Application.config.MAX_TABLE_SIZE) 
  table_list.each do |player_ids|
    table = table.create_with_new_deck
    tables << table
    player_ids.each do |id|
      seat = Seat.create(:table_id => table.id, :player_id => id)
      Player.find_by_id(id).update_attributes(:seat_id => seat.id, :hand => [], :replacement => false)
    end
  end
  tables
end

def setup_hands(player_ids)
  players = Player.find :all, :conditions => ["id in (?)", player_ids]
  players.each do |p|
    p.hand = ["As 2s 3s 4s 5s"]
    p.save
  end
end

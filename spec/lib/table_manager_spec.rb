require 'spec_helper'
# require_relative '../lib/table_manager/table_manager.rb'
# include TableManager

describe TableManager do
  
  it "should error if size of table is less than or equal to 1" do
     players = ["A", "B", "C", "D"]
     table_size = 1
     expect { TableManager.assign(players, table_size) }.to raise_error(Exception)

     table_size = 0
     expect { TableManager.assign(players, table_size) }.to raise_error(Exception)
   end

   it "should make no tables if there are no players" do
     players = []
     table_size = 6
     TableManager.assign(players, table_size).should == []
   end

   it "should put all players in 1 table if there are few players than table_size" do
     players = ["A", "B", "C", "D"]
     table_size = 6
     TableManager.assign(players, table_size).should == [["A", "B", "C", "D"]]
   end

   it "should make P/N tables of N players if P = xN" do 
     players = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
     table_size = 6
     tables = TableManager.assign(players, table_size)
     tables.count.should == 2
     tables.each do |table|
       table.count.should == table_size
     end
   end

   it "should make (P/N).ceil tables if P != xN" do
     players = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
     table_size = 6
     num_of_players = players.count
     tables = TableManager.assign(players, table_size)

     tables.count.should == (num_of_players.to_f / table_size).ceil
   end

   it "should make 2 tables of 5 with 10 players" do
     players = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
     table_size = 6
     tables = TableManager.assign(players, table_size)
     tables.count.should == 2
     tables[0].count.should == 5
     tables[1].count.should == 5
   end

   it "should make a table of 6 and a table of 5 with 11 players" do
     players = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]
     table_size = 6
     tables = TableManager.assign(players, table_size)
     tables.should == [["A", "B", "C", "D", "E", "F"],["G", "H", "I", "J", "K"]]
     tables.count.should == 2
     tables[0].count.should == 6
     tables[1].count.should == 5
   end

   it "should make 4 tables of 5 players wiith 20 players" do
     players = (0...20).map{|i|i.to_s 20}
     table_size = 6
     tables = TableManager.assign(players, table_size)
     tables.count.should == 4
     tables.each do |table|
       table.count.should == 5
     end
   end

   it "should correctly assign a random number of players" do
     size = Random.rand(1..200)
     players = (0..size).map{|i| i}
     table_size = 6
     tables = TableManager.assign(players, table_size)
     players = (0..size).map{|i| i}
     num_of_tables = (players.count.to_f / table_size).ceil
     tables.count.should == (players.count.to_f / table_size).ceil
     big_tables = players.count % num_of_tables
     big_table_size = (players.count.to_f/ num_of_tables).ceil
     small_tables = num_of_tables - big_tables
     small_table_size = (players.count.to_f/ num_of_tables).floor

     tables[0..big_tables-1].each do |big_table|
       big_table.count.should == big_table_size
     end
     tables[big_tables..tables.length-1].each do |small_table|
       small_table.count.should == small_table_size
     end
   end
  
end
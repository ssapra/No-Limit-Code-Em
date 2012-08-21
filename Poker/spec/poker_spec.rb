require 'spec_helper'
require './my_poker_v2'

describe Deck do 
    
    before :each do
      @deck = Deck.new
    end
    
    describe "@new" do 
      it "should have 52 cards" do
        @deck.size.should == 52
      end
      
      it "returns a deck object" do
        @deck.should be_an_instance_of Deck
      end
    end
end

describe "Poker Game" do 
  
  before :each do
    @players = []
    @deck = Deck.new
    5.times do |index|
      @players << Player.new
    end
  end
  
  describe "@new_players" do 
    it "should have 200 chips" do
      @players.each do |player|
        player.data[:stack].should == 200
      end
    end
    
    it "should have a maximum bet of 0" do 
      minimum_bet(@players).should == 0
    end
  end
  
  describe "First time dealing cards" do
    it "should give 5 cards to each player" do
      players, deck = deal(@players, @deck)
      players.each do |player|
        player.data[:hand].count.should == 5
      end
    end
  end
  
  describe "Reseting bets each round" do
    it "should reset bets to 0 even if they each check" do
      reset_round(@players)
      @players.each do |player|
        player.data[:bet].should == 0
      end
    end
    
    it "should reset bets to 0 even if they each bet" do
      @players.each do |player|
        player.data[:bet] = 20
      end
      reset_round(@players)
      @players.each do |player|
        player.data[:bet].should == 0
      end
    end
  end
  
  describe "players are ready when they all have same amount" do 
    it "should be ready if they all check" do
      @players.each do |player|
        player.data[:bet] = 0
        player.data[:action] = 'check'
      end
      players_ready?(@players).should == true
    end
    
    it "should be ready if they all bet the same" do
      @players.each do |player|
        player.data[:bet] = 20
        player.data[:action] = 'bet'
      end
      players_ready?(@players).should == true
    end
    
    it "should not be ready if they all bet differently" do
      @players.each_with_index do |player, index|
        player.data[:bet] = index * 10
      end
      players_ready?(@players).should == false
    end 
  end
  
  describe "Checking the input while replacing cards" do
    it "should check if any numbers are repeated and accept the input" do
      replace = ["1","2","3","1"]
      acceptable_replacement?(replace).should == true
    end
    
    it "should check if any number is out of index" do
      replace = ["1","2","3","6"]
      acceptable_replacement?(replace).should == false
    end
    
    it "should replace the cards even if numbers are out of order" do
      replace = ["1","3","2"]
      acceptable_replacement?(replace).should == true
    end
    
    it "should replace only 1 card" do
     replace = ["3"]
     acceptable_replacement?(replace).should == true
    end
    
    it "should ignore letters" do
     replace = ["e","2"]
     acceptable_replacement?(replace).should == true
    end
  end
end
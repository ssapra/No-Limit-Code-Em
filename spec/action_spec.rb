require 'spec_helper'

describe Action do
  
  describe "#self.check" do
    it "should save the player's check if they can check" do
      player = Player.create(:bet => 0)
      player.stub(:action)
      player.stub(:stack => 0)
      player.stub(:save)
      round = double("round")
      player.stub(:round => round)
      round.stub(:minimum_bet => 0)
      pot = double("pot")
      round.stub(:pot => pot)
      pot.stub!(:total => 0)
      pot.stub(:total=)
      pot.stub(:save)
      Action.stub(:record_valid_action)
      check_amount = 0
      Action.check(player, "check", check_amount)
      Action.should_receive(:save_player_action)
    end
    
    it "should make them fold if they cannot check" do
      
    end
  
  end
  
  describe "#self.bet" do
    
  end
  
  describe "#self.call" do
    
  end
  
  describe "#self.raising" do
    
  end
  
  
  describe "#save_player_action" do
    it "should deduct the correct amount from their stack" do
      pot = double("pot")
      pot.stub(:total => 0)
      pot.stub(:total=)
      pot.stub(:save)
      round = double("round")
      round.stub(:pot => pot)
      player = Player.create
      player.stub(:round => round)
      stack = player.stack
      amount = 20
      Action.stub(:record_valid_action)
      Action.save_player_action(player, "bet", amount)
      player.stack.should == stack - amount
    end
    
    it "should add the correct amount to their bet" do
      pot = double("pot")
      pot.stub(:total => 0)
      pot.stub(:total=)
      pot.stub(:save)
      round = double("round")
      round.stub(:pot => pot)
      player = Player.create
      player.stub(:round => round)      
      stack = player.stack
      amount = 20
      Action.stub(:record_valid_action)
      Action.save_player_action(player, "bet", amount)
      player.bet.should == amount 
    end
      
    it "should add the correct amount to the pot" do
      pot = Pot.create(:total => 0)
      round = double("round")
      round.stub(:pot => pot)
      player = Player.create
      player.stub(:round => round)
      stack = player.stack
      amount = 20
      Action.stub(:record_valid_action)
      Action.save_player_action(player, "bet", amount)
      pot.total.should == amount
    end
    
  end
    
  
  
end
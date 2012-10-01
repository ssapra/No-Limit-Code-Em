require 'spec_helper'

describe Player do
  
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
      # Action.bet(player, "bet", amount)
      player.save_player_action("bet", amount)
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
        player.save_player_action("bet", amount)
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
      player.save_player_action("bet", amount)
      pot.total.should == amount
    end
    
  end
  
  describe "#acceptable_replacement?" do
    
    it "will accept 0 as no replacement" do
      # how to test something like this?
    end
    
    it "shouldn't accept input beyond the range" do
      player = Player.create
      replace = "1 3 8"
      player.acceptable_replacement?(replace).should == false
    end
    
    it "should allow a simple replacement" do
      player = Player.create
      replace = "1 2 3"
      player.acceptable_replacement?(replace).should == true
    end
    
    it "shouldn't allow duplicate cards to be called" do
      player = Player.create
      replace = "1 2 2"
      player.acceptable_replacement?(replace).should == false
    end
    
    it "shouldn't allow more than 3 cards to be replaced" do
      player = Player.create
      replace = "1 2 3 4"
      player.acceptable_replacement?(replace).should == false
    end
  end
  
  describe "#remove_cards" do
    it "should create an array of the discards" do
      player = Player.create(:hand => ["Ts", "Ks", "5c", "4c", "Qs"])
      player.stub!(:round)
      PlayerActionLog.any_instance.stub(:create).and_return(true)
      replace = "3 4"
      cards = player.remove_cards(replace)
      cards.should == ["5c", "4c"]
    end
  end
  
  describe "#new_cards" do
    it "should deal new cards" do
      player = Player.create(:hand => ["Ts", "Ks", "Qs"])
      player.stub(:table)
      table = double('table')
      table.stub(:reload)
      table.stub(:deal).and_return("As")
      table.stub(:save)
      num_needed = 2
      cards = player.new_cards(num_needed)
      cards.should == "As As"
    end
  end
  
end
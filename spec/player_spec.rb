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
      bet_amount = 20
      player.save_player_action("bet", bet_amount, 20, 20)
      player.stack.should == stack - bet_amount
    end
    
  end
  
end
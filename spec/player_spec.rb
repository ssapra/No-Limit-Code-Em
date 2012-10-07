require 'spec_helper'

describe Player do
  
  describe "#acceptable_replacement?" do
    
    pending "will accept 0 as no replacement" do
      player = Player.create
      round = double "round"
      player.stub(:round => round)
      round.stub(:id)
      input = "0"
      player.replace_cards(input)
      PlayerActionLog.should_receive(:create)
      player.should_receive(:reset_after_replacement)
    end
    
    it "shouldn't accept input beyond the range" do
      player = Player.create
      replace = "138"
      player.acceptable_replacement?(replace).should == false
    end
    
    it "should allow a simple replacement" do
      player = Player.create
      replace = "123"
      player.acceptable_replacement?(replace).should == true
    end
    
    it "shouldn't allow duplicate cards to be called" do
      player = Player.create
      replace = "122"
      player.acceptable_replacement?(replace).should == false
    end
    
    it "shouldn't allow more than 3 cards to be replaced" do
      player = Player.create
      replace = "1234"
      player.acceptable_replacement?(replace).should == false
    end
  end
  
  describe "#remove_cards" do
    it "should create an array of the discards" do
      player = Player.create(:hand => ["Ts", "Ks", "5c", "4c", "Qs"])
      round = double("round")
      player.stub!(:round => round)
      round.stub(:id)
      PlayerActionLog.any_instance.stub(:create).and_return(true)
      replace = "34"
      cards = player.remove_cards(replace)
      cards.should == ["5c", "4c"]
    end
  end
  
  describe "#new_cards" do
    it "should deal new cards" do
      player = Player.create(:hand => ["Ts", "Ks", "Qs"])
      table = double('table')
      player.stub(:table => table)
      table.stub(:reload)
      table.stub(:deal).and_return("As")
      table.stub(:save)
      num_needed = 2
      cards = player.new_cards(num_needed)
      cards.should == ["As", "As"]
    end
  end
  
end

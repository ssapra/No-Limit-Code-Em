class Player
  
  attr_accessor :name, :stack, :hand, :bet, :data
  
  def initialize
    @data = {:name => "",
             :hand => [],
             :bet => 0,
             :stack => 200,
             :action => nil,
             :round => true,
             :playing => true}
  end
end
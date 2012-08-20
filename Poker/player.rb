class Player
  
  attr_accessor :name, :stack, :hand, :bet
  
  def initialize(name)
    @name = name
    @stack = 200
    @hand = []
    @bet = nil
  end
end
class Player
  
  attr_accessor :name, :stack, :hand, :bet, :data
  
  def initialize
    @data = {:name => "",
             :hand => [],
             :bet => 0,
             :stack => 200,
             :action => nil,
             :status => true,
             :round => true,
             :playing => true}
  end
  
  def action(min_bet, pot)
    puts "#{self.data[:name]}, here are your cards: #{self.data[:hand]}"          # SUMMARY 
    puts "You have bet #{self.data[:bet]} and the minimum to play is #{min_bet}" 
    puts "You have #{self.data[:stack]} chips in your stack."
    print "Will you check, bet, or fold? (Ex. bet 10) "
    response = gets.chomp.downcase
    if response.split(" ")[0] == 'check'
      if self.check?(min_bet,pot)
        self.data[:action] = true
        pot+= min_bet - self.data[:bet]
        self.data[:stack]-= min_bet - self.data[:bet]
        self.data[:bet] = min_bet
        puts
        puts "#{self.data[:name]} checks"
        puts
      else
        self.data[:status] = false
        puts
        puts "#{self.data[:name]}, you can not check"
        puts "#{self.data[:name]} folds"
        puts
      end
    elsif response.split(" ")[0] == 'bet'
      self.data[:action] = "bet"
      bet = response.split(" ")[1].to_i
      if self.bet?(min_bet, pot, bet)
        self.data[:action] = true
        pot+= min_bet + bet - self.data[:bet]
        self.data[:stack]-= bet+ min_bet - self.data[:bet]
        self.data[:bet] = min_bet + bet
        puts
        puts "#{self.data[:name]} bets #{bet}"
        puts 
      else
        self.data[:status] = false
        puts
        puts "#{self.data[:name]} tried to bet #{bet}, but failed"
        puts "#{self.data[:name]} folds"
        puts
      end
    elsif response.split(" ")[0] == 'fold'
      self.data[:action] = true
      self.data[:status] = false
      puts
      puts "#{self.data[:name]} folds"
      puts
    else 
      self.data[:status] = false
      puts 
      puts "Could not read response. "
      puts "#{self.data[:name]} folds"
      puts
    end
    return pot
  end
  
  def check?(min_bet, pot)
    min_bet - self.data[:bet] <= self.data[:stack]
  end
  
  def bet?(min_bet, pot, bet)
    bet + min_bet - self.data[:bet] <= self.data[:stack] && bet > 0
  end
  
  
  def replace_cards(deck)
    puts
    puts "#{self.data[:name]}, this is your hand: #{self.data[:hand]}"
    print "#{self.data[:name]}, will you replace any cards? (yes/no) "
    response = gets.chomp.downcase
    if response == 'yes'
      print "Which cards will you replace? (Example: 145 )"
      replace = gets.chomp.split("")
      array_of_discards = []
      if self.acceptable_replacement?(replace)
        replace.each do |index|
          array_of_discards << self.data[:hand][index.to_i-1]
        end
        self.data[:hand]-=array_of_discards
        array_of_discards.length.times do 
          self.data[:hand] << deck.deal
        end
      else
        self.data[:status] = false
        puts
        puts "#{self.data[:name]} folds"
        puts
      end
    end
    puts
  end
  
  def acceptable_replacement?(replace) # Check that the input is valid for replacement
    if replace.length == replace.uniq.length
      replace.each do |number|
        if number.to_i < 1 || number.to_i > 5
          return false
        end
      end
    else
      return false
    end
    true
  end
  
end
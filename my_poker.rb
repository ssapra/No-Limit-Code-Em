require 'rubygems'
require 'ruby-poker'

class Player
  
  attr_accessor :name, :stack, :hand, :bet
  
  def initialize(name)
    @name = name
    @stack = 200
    @hand = []
    @bet = 0
  end
end

class Deck
  def initialize
    @cards = []
    Card::SUITS.each_byte do |suit|
      # careful not to double include the aces...
      Card::FACES[1..-1].each_byte do |face|
        @cards.push(Card.new(face.chr, suit.chr))
      end
    end
    shuffle
  end

  def shuffle
    @cards = @cards.sort_by { rand }
    return self
  end

  # removes a single card from the top of the deck and returns it
  # synonymous to poping off a stack
  def deal
    @cards.pop
  end

  # delete an array or a single card from the deck
  # converts a string to a new card, if a string is given
  def burn(burn_cards)
    return false if burn_cards.is_a?(Integer)
    if burn_cards.is_a?(Card) || burn_cards.is_a?(String)
      burn_cards = [burn_cards]
    end

    burn_cards.map! do |c|
      c = Card.new(c) unless c.class == Card
      @cards.delete(c)
    end
    true
  end

  # return count of the remaining cards
  def size
    @cards.size
  end

  def empty?
    @cards.empty?
  end
end

def introduction
  print "How many players? "
  number = gets.chomp.to_i
  players = []
  number.times do |index|  
    print "Player #{index + 1} name: "
    name = gets.chomp
    players << Player.new(name)
    puts "Hi " + players[index].name
  end
  players
end

def init_round?
  puts "Would you like to play Draw Poker? (yes/no)"
  "yes" == gets.chomp.downcase
end

def deal(players, deck)
    5.times do 
      players.each do |player|
        player.hand << deck.deal
      end
    end
  return players, deck
end

def action(players)
  if able_to_check?(players)
    print "Will you check, bet, or fold? "
  else 
    print "Will you bet or fold? "
  end
  response = gets.chomp
  if response == 'check'
    return 0
  end
  if response == 'bet'
    print "How much will you bet? "
    amount = gets.chomp
    amount.to_i
  elsif response == 'fold'
    -1
  end
end

def able_to_check?(players)
  maximum_bet(players) == 0
end

def betting(players, pot)
    while(true) 
      players.each do |player|
          if player.bet > 0
              if player.bet < maximum_bet(players)
                  puts "#{player.name}, here are your cards: #{player.hand}"
                  puts "You have bet #{player.bet} and you have to at least match #{maximum_bet(players)}" 
                  raise_bet = action(players)
                  
                  if raise_bet + player.bet == maximum_bet(players)
                      puts
                      puts "#{player.name} calls #{raise_bet + player.bet}"
                      puts
                      player.bet+=raise_bet
                      player.stack-=raise_bet
                      pot+=raise_bet
                  elsif raise_bet + player.bet > maximum_bet(players)
                      puts
                      puts "#{player.name} raises #{raise_bet}"
                      puts
                      player.bet+=raise_bet
                      player.stack-=raise_bet
                      pot+=raise_bet
                  else 
                      puts
                      puts "#{player.name} folds."
                      puts
                      players.delete(player)
                  end
              end
        
          else
            puts
            puts "#{player.name}, here are your cards: #{player.hand}" 
            puts
            player.bet = action(players)
            
            if player.bet < player.stack && player.bet >= maximum_bet(players)
                if player.bet == 0 then puts "#{player.name} checks" else
                puts "#{player.name} bets #{player.bet}" end
                player.stack-=player.bet
                pot+= player.bet
            else 
                puts
                puts "#{player.name} folds."
                puts
                players.delete(player)
            end
          
          end
          
           puts "-------------------------" 
      end
      
      if(players_ready?(players))
         players = reset_bets(players)
         return players, pot 
      end
  end
end

def reset_bets(players) # Resets bets to 0 
  players.each do |player|
    player.bet = 0
  end
  players
end 

def players_ready?(players)
  max_bet = maximum_bet(players)
  temp_array = []
  temp_array << max_bet
  player_bets = []
  players.each do |player|
    player_bets << player.bet
  end
  
  temp_array * players.count == player_bets
end

def maximum_bet(players) # Maximum bet returned from array of players 
  maximum_bet = 0
  players.each do |player|
    if player.bet > maximum_bet then maximum_bet = player.bet end
  end
  maximum_bet
end

def replacement(players, deck)
  players.each do |player|
    puts "#{player.name}, this is your hand: #{player.hand}"
    print "#{player.name}, will you replace any cards? (yes/no) "
    response = gets.chomp
    if response == 'yes'
      print "Which cards will you replace? (Example: 1,4,5 )"
      replace = gets.chomp.split(",")
      array_of_discards = []
      replace.each do |index|
        array_of_discards << player.hand[index.to_i-1]
      end
      player.hand-=array_of_discards
      array_of_discards.length.times do 
        player.hand << deck.deal
      end
    end
    puts "-------------------------"
  end
  return players, deck
end

def change_array_to_PokerHand(players)
  players.each do |player|
    player.hand = PokerHand.new(player.hand)
  end
  players
end

def determine_winner(players)
  players = change_array_to_PokerHand(players)
  winner = players.max {|a,b| a.hand.rank <=> b.hand.rank }
  winners = []
  players.each do |player|
    if player.hand.rank == winner.hand.rank then winners << player end
  end
  winners
end

def round_over?(players)
  players.count == 1
end

if init_round?
    first_round_players = introduction
    puts "Let's play poker"
    deck = Deck.new
    pot = 0
    puts "There are #{deck.size} cards in the Deck"
    players, deck = deal(first_round_players, deck)
   
    second_round_players, pot = betting(players, pot)
    if round_over?(second_round_players)
        puts "#{second_round_players[0].name} has won #{pot} chips"
    else
        puts "There are #{pot} chips in the pot...Careful now"
        players, deck = replacement(second_round_players, deck)
        last_round_players, pot = betting(players,pot)
        
        if round_over?(last_round_players)
            puts "#{last_round_players[0].name} wins #{pot} chips"
        else
            puts "There are #{pot} chips in the pot...Careful now"
            winners = determine_winner(last_round_players)
            if winners.count == 1
                puts "#{winner.name} has won this round with #{winner.hand}."
                puts "#{pot} chips go to #{winner.name}"
            else 
                division = winners.count
                puts "The pot is split #{division}-way."
                winners.each do |winner|
                   puts "#{winner.name} takes #{pot/division} with #{winner.hand}"
                   winner.stack+=pot/division
                end
            end
            winner.stack+= pot
            puts "Round standings: "
            first_round_players.each do |player|
              puts "#{player.name} has #{player.stack} chips"
            end
        end
     end
end
require 'rubygems'
require './deck.rb'
require './poker_hand.rb'
require './card.rb'
require './player.rb'

def introduction # Checks for multiple players and creates the Player objects
  print "How many players? "
  number = gets.chomp.to_i
  if number > 1
      $players = []
      number.times do |index|  
        print "Player #{index + 1} name: "
        name = gets.chomp
        player = Player.new     # Creation new Player object
        player.data[:name] = name
        $players << player     # Stored into array
        puts "Hi " + name
      end
  else
      puts "There has to be more than 1 player."
      puts "Leaving game table now..."
      puts
      return nil
  end
end

def init_round? # Initializes the game 
  print "Would you like to play Draw Poker? (yes/no) "  
  "yes" == gets.chomp.downcase
end

def deal(deck) #Deals 5 cards to each player
    5.times do 
      $players.each do |player|      # Deals card to each player before it deals second card
        player.data[:hand] << deck.deal
      end
    end
  return deck
end

def betting(pot) # Loop through players as they check/bet/fold/etc
    while(true) 
      $players.each do |player|
            min_bet = minimum_bet
            if player.data[:status] && (player.data[:action].nil? || player.data[:bet] != min_bet)
              pot = player.action(min_bet, pot)
            end
            if players_ready?                                                       # Checks at the end of each player's turn if everyone is ready
              #players = next_player_shift(players,player)                                     # Shifts the players so that the next person is now first in the array
              reset_bets
              puts "There are #{pot} chips in the pot."
              return pot
            end
      end
   end
end

def next_player_shift(player)
  if $players.count != 1  
    while(player)
        # code
    end
  end
end

def reset_bets # Resets bets to 0  and actions to nil
  $players.each do |player|
    player.data[:bet] = 0
    player.data[:action] = nil
  end
end

def count_players
  players_in.count
end 

def players_in
  still_playing = []
  $players.each do |player|
    if player.data[:status] then still_playing << player end
  end
  still_playing
end  

def players_ready? # Checks if everyone bet the minimum amount
  
  if count_players == 1                   # Checks if everyone but one person folded
    true
  else
    min_bet = minimum_bet
    players_in.each do |player|
      if player.data[:action].nil? || player.data[:bet] != min_bet      # Make sure that everyone has had a chance to act or if they haven't put the minimum bet
        return false
      end
    end
    true
  end
end

def minimum_bet # Maximum bet returned from array of players 
  minimum_bet = 0
  players_in.each do |player|
    if player.data[:action] != nil && player.data[:bet] > minimum_bet then minimum_bet = player.data[:bet] end
  end
  minimum_bet
end

def replacement(deck, pot) # Replaces cards with new cards from deck
  players_in.each do |player|
    player.replace_cards(deck)
    if count_players == 1 then determine_winner(pot) end
  end
  return deck
end

def change_array_to_PokerHand(players) # Changes array of cards to PokerHand object for comparison of rank
  players.each do |player|
    player.data[:hand] = PokerHand.new(player.data[:hand])
  end
  players
end

def determine_winner(pot) #Checks for multiple winners and displays summary
  players = change_array_to_PokerHand(players_in)
  winner = players.max {|a,b| a.data[:hand] <=> b.data[:hand] }                             # Compares hands to see which hand is greater
  winners = []
  players.each do |player|
    if player.data[:hand] == winner.data[:hand] then winners << player end                  # If the selected hand ties any other hand, pot will be split
  end
  if winners.count == 1
      puts "#{winners[0].data[:name]} has won this round with #{winners[0].data[:hand]}."
      puts "#{winners[0].data[:name]} wins #{pot} chips"
      winner.data[:stack]+= pot
  else 
      division = winners.count
      puts "The pot is split #{division}-way."
      winners.each do |winner|
         puts "#{winner.data[:name]} takes #{pot/division} with #{winner.data[:hand]}"
         winner.data[:stack]+=pot/division                                                    # Correct amount of chips given to each winner !! Extra chips? 110 / 3
      end
  end
end

def round_summary
  puts
  puts "Round standings: "
  $players.each do |player|
    puts "#{player.data[:name]} has #{player.data[:stack]} chips"
    if player.data[:stack] == 0
      puts
      puts "#{player.data[:name]} has left the table"
      puts
      players.delete(player)
    end
  end
  return reset_round
end

def reset_round
  $players.each do |player|
    player.data[:status] = true
    player.data[:bet] = 0
    player.data[:hand] = []
  end
end

def begin_game
  
if init_round?
      introduction
      if $players
        puts
        puts "Let's play poker"
        deck = Deck.new
        pot = 0
        while($players.count > 1)
            puts "Dealing cards..."
            puts
            deck = deal(deck)
            pot = betting(pot)
              
            if count_players == 1                                          # If only one player remains, winner is declared and round is over
                determine_winner(pot)
            else
                deck = replacement(deck, pot)
                pot = betting(pot)
        
                if count_players == 1   
                    determine_winner(pot)                                   # If only one player remains, winner is declared and round is over
                else  
                    determine_winner(pot)
                end
            end
            round_summary
            pot = 0
            deck = Deck.new
            puts 
      end
      puts "The game is over"
      puts "#{$players[0]} has won!"
      puts "Deconstructing game table now..."
  end
end
end

begin_game
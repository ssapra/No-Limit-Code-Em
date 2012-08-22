require 'rubygems'
require './deck.rb'
require './poker_hand.rb'
require './card.rb'
require './player.rb'

def introduction # Checks for multiple players and creates the Player objects
  print "How many players? "
  number = gets.chomp.to_i
  if number > 1
      players = []
      number.times do |index|  
        print "Player #{index + 1} name: "
        name = gets.chomp
        player = Player.new     # Creation new Player object
        player.data[:name] = name
        players << player     # Stored into array
        puts "Hi " + players[index].data[:name]
      end
      players
  else
      puts "There has to be more than 1 player."
      puts "Leaving game table now..."
      puts
      return nil
  end
end

def init_round? # Initializes the game 
  puts "Would you like to play Draw Poker? (yes/no)"  
  "yes" == gets.chomp.downcase
end

def deal(players, deck) #Deals 5 cards to each player
    5.times do 
      players.each do |player|      # Deals card to each player before it deals second card
        player.data[:hand] << deck.deal
      end
    end
  return players, deck
end

def action(player) # Asks for player action
  print "Will you check, bet, or fold? "
  response = gets.chomp
  if response.split(" ")[0] == 'check'
    player.data[:action] = "check"
  elsif response.split(" ")[0] == 'bet'
    player.data[:action] = "bet"
    player.data[:bet] = response.split(" ")[1].to_i
  else
    player.data[:action] = "fold"
  end
  return player
end

def betting(players, pot) # Loop through players as they check/bet/fold/etc
    while(true) 
      players.each do |player|
            if player.data[:action] != nil      # Player has already checked or bet
                if player.data[:bet] < minimum_bet(players) # Player has to check, bet or fold now
                    puts "#{player.data[:name]}, here are your cards: #{player.data[:hand]}"          # SUMMARY 
                    puts "You have bet #{player.data[:bet]} and you have to at least match #{minimum_bet(players)}" 
                    puts "You have #{player.data[:stack]} chips in your stack."
                    puts
                    temp_player = Player.new          # Temp player created so that original bet is not lost
                    temp_player = action(temp_player)
                    min_bet = minimum_bet(players)  # Minimum bet re-checked
                    
                    if temp_player.data[:action] == "check" && (min_bet - player.data[:bet]) <= player.data[:stack] # If player checks and has enough to check
                      difference = min_bet - player.data[:bet]
                      pot+= difference                              # Appropriate changes to the pot and player's stack
                      player.data[:stack]-= difference
                      player.data[:bet] = min_bet                   # Bet is reset to the minimum bet
                      puts
                      puts "#{player.data[:name]} checks"              
                      puts
                    elsif temp_player.data[:bet] + min_bet - player.data[:bet] <= player.data[:stack] && temp_player.data[:bet] > 0 # If raise is less than player stack and more than the minimum bet
                      puts
                      puts "#{player.data[:name]} bets #{temp_player.data[:bet]}"
                      puts
                      player.data[:stack]-= temp_player.data[:bet] + min_bet - player.data[:bet]   
                      pot+= temp_player.data[:bet] + min_bet - player.data[:bet]
                      player.data[:bet] = temp_player.data[:bet] + min_bet                        # Player's new bet correctly re-assigned
                    else 
                      puts
                      puts "#{player.data[:name]} folds."
                      puts
                      players = players - [player]
                    end
                end
        
            else                                                                              # First time betting
                puts "#{player.data[:name]}, here are your cards: #{player.data[:hand]}." 
                puts "The minimum bet is #{minimum_bet(players)}."
                puts "You have #{player.data[:stack]} chips in your stack."
                puts
                min_bet = minimum_bet(players)                                                # Minimum bet starts at 0
                player = action(player)
               
                if player.data[:action] == "check" && min_bet <= player.data[:stack]          # If player checks, he bets 0
                  player.data[:bet] = min_bet
                  player.data[:stack]-=min_bet
                  pot+=player.data[:bet]
                  puts
                  puts "#{player.data[:name]} checks"              
                  puts
                elsif player.data[:bet] <= player.data[:stack] && player.data[:bet] > 0     
                  puts
                  puts "#{player.data[:name]} bets #{player.data[:bet]}"
                  puts
                  player.data[:bet]+=min_bet                                                  # Minimum bet and player's bet updates total bet 
                  player.data[:stack]-=player.data[:bet]
                  pot+= player.data[:bet]                                                     # Pot increases by appropriate amount
                else 
                  puts
                  puts "#{player.data[:name]} folds."
                  puts
                  players = players - [player]
                end
            end
            
            if(players_ready?(players))                                                       # Checks at the end of each player's turn if everyone is ready
              #players = next_player_shift(players,player)                                     # Shifts the players so that the next person is now first in the array
              reset_round(players)
              return players, pot
            end
      end
   end
end

def next_player_shift(players, player)
  while(player != players.last)
    temp_player = players.last
    players-= [players.last]
    players.unshift(temp_player)
  end
  players
end

def reset_round(players) # Resets bets to 0  and actions to nil
  players.each do |player|
    player.data[:bet] = 0
    player.data[:action] = nil
  end
  players
end 

def players_ready?(players) # Checks if everyone bet the minimum amount
  
  if players.count == 1                   # Checks if everyone but one person folded
    true
  else
    min_bet = minimum_bet(players)
    players.each do |player|
      if player.data[:action] == nil || player.data[:bet] != min_bet      # Make sure that everyone has had a chance to act or if they haven't put the minimum bet
        return false
      end
    end
  end
end

def minimum_bet(players) # Maximum bet returned from array of players 
  minimum_bet = 0
  players.each do |player|
    if player.data[:bet] != nil && player.data[:bet] > minimum_bet then minimum_bet = player.data[:bet] end
  end
  minimum_bet
end

def replacement(players, deck, pot) # Replaces cards with new cards from deck
  players.each do |player|
    puts
    puts "#{player.data[:name]}, this is your hand: #{player.data[:hand]}"
    print "#{player.data[:name]}, will you replace any cards? (yes/no) "
    response = gets.chomp
    if response == 'yes'
      print "Which cards will you replace? (Example: 145 )"
      replace = gets.chomp.split("")
      array_of_discards = []
      if acceptable_replacement?(replace)
        replace.each do |index|
          array_of_discards << player.data[:hand][index.to_i-1]
        end
        player.data[:hand]-=array_of_discards
        array_of_discards.length.times do 
          player.data[:hand] << deck.deal
        end
      else
        puts "#{player.data[:name]} folds"
        players = players - [player]
      end
    end
    if players.count == 1 # If everyone folds/exits game, winner must be determined now
      determine_winner(players, pot)
    end
  end
  puts
  return players, deck
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

def change_array_to_PokerHand(players) # Changes array of cards to PokerHand object for comparison of rank
  players.each do |player|
    player.data[:hand] = PokerHand.new(player.data[:hand])
  end
  players
end

def determine_winner(players, pot) #Checks for multiple winners and displays summary
  players = change_array_to_PokerHand(players)
  winner = players.max {|a,b| a.data[:hand] <=> b.data[:hand] }                             # Compares hands to see which hand is greater
  winners = []
  players.each do |player|
    if player.data[:hand] == winner.data[:hand] then winners << player end                  # If the selected hand ties any other hand, pot will be split
  end
  if winners.count == 1
      puts "#{winners[0].data[:name]} has won this round with #{winners[0].data[:hand]}."
      puts "#{pot} chips go to #{winners[0].data[:name]}"
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

def round_summary(players)
  puts
  puts "Round standings: "
  players.each do |player|
    puts "#{player.data[:name]} has #{player.data[:stack]} chips"
    player.data[:bet] = 0; player.data[:hand] = []
    if player.data[:stack] == 0
      players = players - [player]
      puts "#{player.data[:name]} has left the table"
    end
  end
  return reset_round(players)
end

def begin_game
  
if init_round?
    first_round_players = introduction
    if first_round_players
        puts
        puts "Let's play poker"
        deck = Deck.new
        pot = 0
        while(first_round_players.count > 1)
            puts "Dealing cards..."
            puts
            players, deck = deal(first_round_players, deck)
            second_round_players, pot = betting(players, pot)
              
            if second_round_players.count == 1                                          # If only one player remains, winner is declared and round is over
                puts "#{second_round_players[0].data[:name]} wins #{pot} chips"
                second_round_players[0].data[:stack]+=pot
            else
                puts "There are #{pot} chips in the pot...Careful now"
                players, deck = replacement(second_round_players, deck, pot)
                last_round_players, pot = betting(players,pot)
        
                if last_round_players.count == 1                                        # If only one player remains, winner is declared and round is over
                    puts "#{last_round_players[0].data[:name]} wins #{pot} chips"
                    last_round_players[0].data[:stack]+=pot
                else  
                    puts "There are #{pot} chips in the pot...Careful now"
                    puts
                    determine_winner(last_round_players, pot)
                end
            end
            first_round_players = round_summary(first_round_players)
            pot = 0
            deck = Deck.new
            puts 
      end
      puts "The game is over"
      puts "#{first_round_players[0].data[:name]} has won!"
      puts "Deconstructing game table now..."
  end
end
end

begin_game
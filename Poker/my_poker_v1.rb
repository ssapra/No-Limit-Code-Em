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
        players << Player.new(name)
        puts "Hi " + players[index].name
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
      players.each do |player|
        player.hand << deck.deal
      end
    end
  return players, deck
end

def action(players) # Asks for player action
  if maximum_bet(players) == 0
    print "Will you check, bet, or fold? "
  else 
    print "Will you bet or fold? "
  end
  response = gets.chomp
  if response == 'check'
    return 0
  elsif response == 'bet'
    print "How much will you bet? "
    amount = gets.chomp
    amount.to_i
  else
    -1
  end
end

def betting(players, pot) # Loop through players as they check/bet/fold/etc
    while(true) 
      players.each do |player|
            if player.bet != nil && player.bet > 0
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
                        players = players - [player]
                    end
                end
        
            else 
                puts
                puts "#{player.name}, here are your cards: #{player.hand}." 
                puts "The maximum bet is #{maximum_bet(players)}."
                puts "You have #{player.stack} chips in your stack."
                puts
                player.bet = action(players)
            
                if player.bet <= player.stack && player.bet >= maximum_bet(players)
                  if player.bet == 0 then puts "#{player.name} checks" else
                    puts "#{player.name} bets #{player.bet}" end
                  player.stack-=player.bet
                  pot+= player.bet
                else 
                  puts
                  puts "#{player.name} folds."
                  puts
                  players = players - [player]
                end
            end
            
            if(players_ready?(players))
              reset_bets(players)
              return players, pot
            end
      end
   end
end

def reset_bets(players) # Resets bets to 0 
  players.each do |player|
    player.bet = nil
  end
  players
end 

def players_ready?(players) # Checks if everyone bet the maximum amount
  
  if players.count == 1
    true
  else
    max_bet = maximum_bet(players)
    temp_array = []
    temp_array << max_bet
    player_bets = []
    players.each do |player|
      if player.bet == nil
        return false
      end
      player_bets << player.bet
    end
  
    temp_array * players.count == player_bets
  end
end

def maximum_bet(players) # Maximum bet returned from array of players 
  maximum_bet = 0
  players.each do |player|
    if player.bet != nil && player.bet > maximum_bet then maximum_bet = player.bet end
  end
  maximum_bet
end

def replacement(players, deck, pot) # Replaces cards with new cards from deck
  players.each do |player|
    puts "#{player.name}, this is your hand: #{player.hand}"
    print "#{player.name}, will you replace any cards? (yes/no) "
    response = gets.chomp
    if response == 'yes'
      print "Which cards will you replace? (Example: 145 )"
      replace = gets.chomp.split("")
      array_of_discards = []
      if acceptable_replacement?(replace)
        replace.each do |index|
          array_of_discards << player.hand[index.to_i-1]
        end
        player.hand-=array_of_discards
        array_of_discards.length.times do 
          player.hand << deck.deal
        end
      else
        puts "#{player.name} folds"
        players = players - [player]
      end
    end
    if players.count == 1 # If everyone folds/exits game, winner must be determined now
      determine_winner(players, pot)
    end
  end
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
    player.hand = PokerHand.new(player.hand)
  end
  players
end

def determine_winner(players, pot) #Checks for multiple winners and displays summary
  players = change_array_to_PokerHand(players)
  winner = players.max {|a,b| a.hand.rank <=> b.hand.rank }
  winners = []
  players.each do |player|
    if player.hand == winner.hand then winners << player end
  end
  if winners.count == 1
      puts "#{winners[0].name} has won this round with #{winners[0].hand}."
      puts "#{pot} chips go to #{winners[0].name}"
      winner.stack+= pot
  else 
      division = winners.count
      puts "The pot is split #{division}-way."
      winners.each do |winner|
         puts "#{winner.name} takes #{pot/division} with #{winner.hand}"
         winner.stack+=pot/division
      end
  end
end

def round_summary(players)
  puts
  puts "Round standings: "
  players.each do |player|
    puts "#{player.name} has #{player.stack} chips"
    player.bet = nil; player.hand = []
    if player.stack == 0
      players = players - [player]
      puts "#{player.name} has left the table"
    end
  end
  return players
end

def begin_game
if init_round?
    first_round_players = introduction
    if first_round_players
      puts "Let's play poker"
      deck = Deck.new
      pot = 0
      while(first_round_players.count > 1)
      puts "There are #{deck.size} cards in the Deck"
      players, deck = deal(first_round_players, deck)
      second_round_players, pot = betting(players, pot)
      if second_round_players.count == 1
          puts "#{second_round_players[0].name} wins #{pot} chips"
          second_round_players[0].stack+=pot
      else
          puts "There are #{pot} chips in the pot...Careful now"
          players, deck = replacement(second_round_players, deck, pot)
          last_round_players, pot = betting(players,pot)
        
          if last_round_players.count == 1
              puts "#{last_round_players[0].name} wins #{pot} chips"
              last_round_players[0].stack+=pot
          else
              puts "There are #{pot} chips in the pot...Careful now"
              determine_winner(last_round_players, pot)
          end
       end
       first_round_players = round_summary(first_round_players)
       pot = 0
       deck = Deck.new
      end
      puts
      puts "The game is over"
      puts "#{first_round_players[0].name} has won"
  end
end
end

#begin_game
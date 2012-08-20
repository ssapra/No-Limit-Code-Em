require './player.rb'
require 'rubygems'

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


puts "Here is everyone"

puts players

players.each do |player|
  puts player.data
  puts
  puts player.data[:summary]
end


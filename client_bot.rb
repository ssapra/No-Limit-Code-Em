require 'net/http'
require 'json'


#############################################################


  print "Name: "
  name = gets.chomp
  print "ID: "
  game_id = gets.chomp
  
  begin
    hostname = "localhost"; port = "3000"
    # url = URI.parse("http://enovapoker.herokuapp.com/")
    url = URI.parse("http://localhost:3000/")
    response = Net::HTTP.post_form(url, {:name => name, :game_id => game_id})
    resp = JSON.parse(response.body)
    if resp.has_key?("player_key")
      puts "Your player key: #{resp["player_key"]}"
      player_key = resp["player_key"]
    else
      puts resp["message"]
    end
  rescue
    puts "Did not connect"
  end

#############################################################
  # 
  # print "Name: "
  # name = gets.chomp 
  # print "ID: "
  # game_id = gets.chomp
  # print "Player Key: "
  # player_key = gets.chomp
  # 
  #############################################################


  play = true
  state = nil
  betting_summary = nil
  replacement_summary = nil
  last_summary = nil
while play
  
  # uri = URI('http://enovapoker.herokuapp.com/game_state')
  uri = URI('http://localhost:3000/game_state')
  
  uri.query = URI.encode_www_form({:name => name, :game_id => game_id, :player_key => player_key})
  
  res = Net::HTTP.get_response(uri)
  answer = JSON.parse(res.body)
  if answer["play"] && answer["replacement"]
    state = nil
    puts "----------------------------------------------"
    puts "Replacement Round"
    puts
    if answer["replacement_summary"] != [] then puts answer["replacement_summary"]; puts; end
    puts "Your hand: #{answer["hand"]}"
    puts "Type which cards you want to replace." 
    puts "0 for no replacement. Type 13 to replace 1st and 3rd card."
    puts ">> 0"
    play = 0
    # url = URI('http://enovapoker.herokuapp.com/player')
    url = URI('http://localhost:3000/player')
    response = Net::HTTP.post_form(url, {:name => name, :game_id => game_id, :player_key => player_key, :player_action => "replacement", :parameters => play})
    puts
    puts "----------------------------------------------"
  elsif answer["play"]
    state = nil  

    if last_summary != answer["round_summary"] && answer["round_summary"] != [[], []] && answer["round_summary"] != []
      puts answer["betting_summary"]
      puts " "
      puts "Hand Ended"
      puts answer["round_summary"]
      puts "==========================================="
      puts "New Hand"
      puts " "
      last_summary = answer["round_summary"]
    end

    puts "----------------------------------------------"
    puts "Betting Round"
    puts
    if answer["betting_summary"] != [] then puts answer["betting_summary"]; puts; end
    puts "Your hand: #{answer["hand"]}"
    puts "There are #{answer["pot"]} chips in the pot."
    puts "The minimum amount to play is #{answer["min_bet"]}."
    puts "You have bet #{answer["bet"]} chips and you have #{answer["stack"]} chips in your stack."
    if answer["bet"] != answer["min_bet"] 
      puts "Maximum Raise: #{answer["max_raise"]}"
      puts "Will you call, raise, or fold?" 
      #number = Random.new.rand(0..3)
      #if number == 0 then play = "fold" else play = "call" end
      play = "call"
    else
      puts "Maximum Bet: #{answer["max_bet"]}"
      puts "Will you check, bet, or fold?"
      max = answer["max_bet"].to_i
      play = "bet #{Random.new.rand(0..max/3)}"
    end
    # print ">> "
    # play = gets.chomp
    puts ">> #{play}"
    # url = URI('http://enovapoker.herokuapp.com/player')
    url = URI('http://localhost:3000/player')
    response = Net::HTTP.post_form(url, {:name => name, :game_id => game_id, :player_key => player_key, :player_action => play.split(" ")[0], :parameters => play.split(" ")[1]})
    puts
    puts "----------------------------------------------"
  elsif answer["game_over"] == true
    puts answer["round_summary"]
    puts
    puts answer["winning_summary"]
    play = false
  else
    if answer["current_player"] && answer["replacement"]
      current_state = "#{answer["current_player"]} is replacing cards."
    elsif answer["current_player"]
      current_state = "#{answer["current_player"]} is betting."
    elsif answer["waiting"] 
      current_state = answer["message"]
      # if answer["round_summary"] then round_summary = answer["round_summary"] end
    else
      current_state = answer["message"]
    end
    # 
    # if answer["round_summary"] != nil
    #   round_summary = answer["round_summary"]
    # end
    
    if state != current_state         # Stop repetition of same phrase
      puts current_state
      state = current_state
    end
    
    if last_summary != answer["round_summary"] && answer["round_summary"] != [[], []] && answer["round_summary"] != []
      puts answer["betting_summary"]
      puts " "
      puts "Hand Ended"
      puts answer["round_summary"]
      puts "==========================================="
      puts "New Hand"
      puts " "
      last_summary = answer["round_summary"]
      state = nil
    end
  end
  
  sleep 3
  
end

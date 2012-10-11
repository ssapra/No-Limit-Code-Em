require 'net/http'
require 'json'

namespace :bot do
  task :run_many do
    bot_runner
  end

  task :treydizzle do
    bot_runner true
  end

  task :run do
    run_bot!
  end

  def bot_runner(smart = false)
    num = ENV['num'].to_i

    threads = num.times.collect do |i| 
      Thread.new do 
        puts "\nThread #{i} lives!"
        run_bot!(smart)
        puts "\nThread #{i} dies!"
      end
    end

    threads.map(&:join)
  end

  def run_bot!(smart = false)
    name = ENV['name'] || SecureRandom.uuid.first(6)
    
    puts "Bot spinning up, attempting to register with name #{name}..."
    
    Net::HTTP.new(ENV['server'] || 'localhost', ENV['port'] || 3000).start do |http|
      request = Net::HTTP::Post.new("/")
      request.set_form_data(:name => name, :game_id => 1000000+rand(10000))
   
      response = http.request request
      puts "response: #{response.body}\n"

      player_json = JSON.parse(response.body)
      key = player_json["player_key"]
      if smart
        dumber_bot_logic(http, name, key)
      else
        dumb_bot_logic(http, name, key)
      end
    end
  end

  def game_state(http, name, key)
    request = Net::HTTP::Get.new("/game_state?name=#{name}&player_key=#{key}")
    http.request request
  end

  def player_action(http, name, key, action, parameter)
    request = Net::HTTP::Post.new("/player")
    request.set_form_data(:name => name, :player_key => key, :player_action => action, :parameters => parameter)
    http.request request
  end

  def dumb_bot_logic(http, name, key)
    while true 
      sleep (ENV['delay'] && ENV['delay'].to_f) || 1
      response = game_state(http, name, key)

      turn_data = JSON.parse(response.body)
      action, parameter = "", ""
      
      if turn_data["play"]
        puts "Deciding on action..."
      
        if turn_data["replacement"]
          action = "replacement"
          parameter = (1..5).to_a.shuffle.first(rand(3)).join
        elsif turn_data["min_bet"] > 0
          if rand(10) < 6
            action = "raise"
            parameter = turn_data['min_bet']
          else
            action = "fold"
          end
        else
          action = "check"
        end
      else
        next
      end

      puts "#{action} #{parameter}"
      response = player_action(http, name, key, action, parameter)

    end
  end # dumb bot

  def dumber_bot_logic(http, name, key)
    play = true
    state = nil
    betting_summary = nil
    replacement_summary = nil
    last_summary = nil
    while play
      res = game_state(http, name, key)
      answer = JSON.parse(res.body)
      if answer["play"] && answer["replacement"]
        state = nil
        play = (rand*10000000000).to_i.to_s.split('').uniq.select{ |x| x.to_i >= 1 && x.to_i <= 5 }.first(3).join
        if rand(5) == 1
          rand_action_lol = "raise"
          play = "30"
        else
          rand_action_lol = "replacement"
        end
        response = player_action(http, name, key, rand_action_lol, play)
      elsif answer["play"]
        state = nil  

        if last_summary != answer["round_summary"] && answer["round_summary"] != [[], []]
          last_summary = answer["round_summary"]
        end
        if answer["bet"] != answer["min_bet"] 
          number = Random.new.rand(0..6)
          if number == 0 then play = "fold"
          elsif number == 2 then play = "replacement 1"
          else play = "call" end
        else
          max = answer["max_bet"].to_i
          play = "bet #{Random.new.rand(max/3..max)}"
        end
        response = player_action(http, name, key, play.split(" ")[0], play.split(" ")[1])
      elsif answer["game_over"] == true
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
        
        if state != current_state         # Stop repetition of same phrase
          state = current_state
        end
        
        if last_summary != answer["round_summary"] && answer["round_summary"] != [[], []]
          last_summary = answer["round_summary"]
          state = nil
        end
      end
      sleep 0 + (rand(4) == 1 ? 7 : 0)
    end
    puts "#{ name } is out"
  end # dumber bot

end

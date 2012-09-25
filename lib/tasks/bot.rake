require 'net/http'
require 'json'

namespace :bot do
  task :run do
    name = ENV['name'] || SecureRandom.uuid.first(6)
    
    puts "Bot spinning up, attempting to register with name #{name}..."
    
    Net::HTTP.new(ENV['server'] || 'localhost', ENV['port'] || 3000).start do |http|

      request = Net::HTTP::Post.new("/")
      request.set_form_data(:name => name, :game_id => 4)
   
      response = http.request request

      player_json = JSON.parse(response.body)
      key = player_json["player_key"]
    
      while true 
        sleep ENV['delay'].to_f || 1
        request = Net::HTTP::Get.new("/game_state?name=#{name}&player_key=#{key}")
        response = http.request request

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

        request = Net::HTTP::Post.new("/player")
        request.set_form_data(:name => name, :player_key => key, :player_action => action, :parameters => parameter)
        response = http.request request
      end
    end
  end

end

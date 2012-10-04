class ApplicationController < ActionController::Base
  protect_from_forgery
  include RubyPoker
  include ApplicationHelper
  include PlayersHelper
  helper_method :respond_to_request,
                :empty_seats
  protected
  
  def empty_seats
    count = 0
    Table.all.each do |table|
      table.players.each do |player|
        if player.in_game == false
          count+=1
        end
      end
    end
    return count
  end
      
  
  def respond_to_request(name, game_id)
    temp_player = Player.find_by_name_and_game_id(name, game_id)      
    if temp_player
      if Digest::MD5.hexdigest("#{temp_player.name} #{temp_player.game_id} TREY") == temp_player.player_key # If they are the correct player, 
        if Status.first.registration
          body = {:message => "You have already registered. Registration is closed. Waiting for game to begin."}
        else
          body = {:message => "Game is about to begin."}
        end
      else 
        body = {:message => "Invalid name/game_id combination."}
      end
    elsif Status.first.registration # If registration is still toggled on
      player = Player.new(:name => name, :game_id => game_id)
      if player.valid?          # Checks if name and game_id are unique and valid
        player.player_key = Digest::MD5.hexdigest("#{player.name} #{player.game_id} TREY")  #player key assigned
        player.save
        body = {:message => "You have successfully registered!", :player_key => player.player_key, :player_name => player.name, :game_id => player.game_id}
      else
        body = {:message => "Invalid inputs. Make sure to enter a valid ID with at least 6 digits."}
      end
    else                      # If registration is already closed, too bad
      body = {:message => "Sorry, registration has closed."}
    end
    return body
  end

private
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "/usr/bin/rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end
  
end

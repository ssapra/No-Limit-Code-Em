require 'json'

class Status < ActiveRecord::Base
  attr_accessible :game, 
                  :registration,
                  :waiting
  
  def self.current_state
    leaderboard = get_leaderboard
    players_at_tables = get_players_at_tables
    return { :leaderboard => leaderboard, :tables => players_at_tables }.as_json
  end

  def self.get_leaderboard
    leaderboard = {}
    rank = 1
    Player.where("losing_time is null").order("stack DESC").each do |player|
      leaderboard[player.id] = { :rank => rank,
                                 :name => player.name,
                                 :stack => player.stack,
                                 :table => (player.table && player.table.id),
                                 :losing_time => nil }
      rank += 1
    end
    PlayerActionLog.where("action = 'lost' or action = 'won'").order("id DESC").each do |pal|
      player = Player.find(pal.player_id)
      leaderboard[player.id] = { :rank => rank,
                                 :name => player.name,
                                 :stack => (rank == 1 ? player.stack : 0),
                                 :table => (player.table && player.table.id),
                                 :losing_time => (rank == 1 ? nil : player.losing_time) }
      rank += 1
    end

    return leaderboard
  end

  def self.get_players_at_tables
    tables = {}
    Table.order(:id).each do |table|
      begin
        tables[table.id] = { :last_winner => table.last_winner,
                             :players => table.players.where("in_game = true") }
      rescue
        # table has been destroyed, do nothing
      end
    end
    tables
  end

end

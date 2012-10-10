class HomeController < ApplicationController
  def index
    @scoreboard = Status.get_leaderboard
    @tables = Status.get_players_at_tables
  end
end

class AddTournamentToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :tournament, :boolean
  end
end

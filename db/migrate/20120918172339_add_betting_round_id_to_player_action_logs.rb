class AddBettingRoundIdToPlayerActionLogs < ActiveRecord::Migration
  def change
    add_column :player_action_logs, :betting_round_id, :integer
  end
end

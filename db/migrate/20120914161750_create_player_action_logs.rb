class CreatePlayerActionLogs < ActiveRecord::Migration
  def change
    create_table :player_action_logs do |t|
      t.integer :hand_id
      t.integer :player_id
      t.string :action
      t.integer :amount
      t.string :cards
      t.string :comment

      t.timestamps
    end
  end
end

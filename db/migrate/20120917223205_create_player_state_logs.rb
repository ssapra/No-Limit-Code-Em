class CreatePlayerStateLogs < ActiveRecord::Migration
  def change
    create_table :player_state_logs do |t|
      t.integer :hand_id
      t.integer :player_id
      t.integer :chip_count

      t.timestamps
    end
  end
end

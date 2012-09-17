class CreateHandLogs < ActiveRecord::Migration
  def change
    create_table :hand_logs do |t|
      t.integer :hand_id
      t.integer :table_id
      t.text :players_ids
      t.integer :dealer_seat_id

      t.timestamps
    end
  end
end

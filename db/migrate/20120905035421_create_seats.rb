class CreateSeats < ActiveRecord::Migration
  def change
    create_table :seats do |t|
      t.integer :table_id
      t.integer :player_id

      t.timestamps
    end
  end
end

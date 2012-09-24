class CreatePots < ActiveRecord::Migration
  def change
    create_table :pots do |t|
      t.integer :total
      t.integer :round_id
      t.text :player_ids

      t.timestamps
    end
  end
end

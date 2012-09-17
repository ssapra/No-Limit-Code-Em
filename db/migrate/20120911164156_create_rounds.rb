class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :pot
      t.integer :min_bet
      t.boolean :first_bet
      t.boolean :second_bet
      t.integer :table_id

      t.timestamps
    end
  end
end

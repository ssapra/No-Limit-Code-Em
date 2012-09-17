class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :game_id
      t.string :name
      t.string :player_key

      t.timestamps
    end
  end
end

class AddIndexToPlayersName < ActiveRecord::Migration
  def change
    add_index :players, :name
  end
end

class AddReplacmentToPlayers < ActiveRecord::Migration
  def up
    add_column :players, :replacement, :boolean
  end
  
  def down
    remove_column :players, :turn
    remove_column :players, :table_id
  end
end

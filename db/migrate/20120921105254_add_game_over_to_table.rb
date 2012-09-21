class AddGameOverToTable < ActiveRecord::Migration
  def change
    add_column :tables, :game_over, :boolean
  end
end

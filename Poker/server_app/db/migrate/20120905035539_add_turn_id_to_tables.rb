class AddTurnIdToTables < ActiveRecord::Migration
  def change
    add_column :tables, :turn_id, :integer
  end
end

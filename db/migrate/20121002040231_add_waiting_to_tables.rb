class AddWaitingToTables < ActiveRecord::Migration
  def change
    add_column :tables, :waiting, :boolean
  end
end

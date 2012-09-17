class AddPlaceholderIdToTables < ActiveRecord::Migration
  def change
    add_column :tables, :placeholder_id, :integer
  end
end

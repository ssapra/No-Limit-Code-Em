class AddMinBetToTables < ActiveRecord::Migration
  def change
    add_column :tables, :min_bet, :integer
  end
end

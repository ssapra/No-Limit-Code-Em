class AddBettingRoundToTables < ActiveRecord::Migration
  def change
    add_column :tables, :betting_round, :integer
  end
end

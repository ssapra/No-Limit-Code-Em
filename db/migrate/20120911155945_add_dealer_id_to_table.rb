class AddDealerIdToTable < ActiveRecord::Migration
  def change
    add_column :tables, :dealer_id, :integer
  end
end

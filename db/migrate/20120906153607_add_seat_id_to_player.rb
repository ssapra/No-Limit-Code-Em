class AddSeatIdToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :seat_id, :integer
  end
end

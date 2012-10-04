class AddLosingTimeToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :losing_time, :datetime
  end
end

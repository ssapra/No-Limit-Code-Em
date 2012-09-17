class AddWaitingToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :waiting, :boolean
  end
end

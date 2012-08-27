class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :hostname
      t.integer :port_number
      t.string :name

      t.timestamps
    end
  end
end

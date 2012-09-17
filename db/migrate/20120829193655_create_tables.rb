class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.integer :pot
      t.text :deck

      t.timestamps
    end
  end
end

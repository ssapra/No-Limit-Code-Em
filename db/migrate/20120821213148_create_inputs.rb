class CreateInputs < ActiveRecord::Migration
  def create
    create_table :inputs do |t|
      t.string :data

      t.timestamps
    end
  end
end

class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.boolean :registration,
      t.boolean :game,
      t.boolean :play,

      t.timestamps
    end
  end
end

class ChangeDataTypeForPlayerGameId < ActiveRecord::Migration
  def up
    change_table :players do |t|
      t.change :game_id, :integer
    end
  end

  def down
    change_table :players do |t|
      t.change :game_id, :string
    end
  end
end

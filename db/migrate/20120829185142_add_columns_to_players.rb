class AddColumnsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :hand,     :text,      :default => []
    add_column :players, :bet,      :integer,   :default => 0
    add_column :players, :stack,    :integer,   :default => 500
    add_column :players, :action,   :string,    :default => nil   
    add_column :players, :in_game,  :boolean,   :default => true
    add_column :players, :in_round, :boolean,   :default => true
    add_column :players, :turn,     :boolean,   :default => false
    add_column :players, :table_id, :integer
  end
end

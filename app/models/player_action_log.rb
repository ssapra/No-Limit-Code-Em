class PlayerActionLog < ActiveRecord::Base
  attr_accessible :action, :amount, :cards, :comment, :hand_id, :player_id, :betting_round_id

  def table
    table_id = HandLog.find(hand_id).table_id
    Table.find_by_id(table_id)
  end
end

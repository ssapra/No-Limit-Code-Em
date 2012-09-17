class PlayerActionLog < ActiveRecord::Base
  attr_accessible :action, :amount, :cards, :comment, :hand_id, :player_id
end

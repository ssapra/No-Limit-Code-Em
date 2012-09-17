class PlayerStateLog < ActiveRecord::Base
  attr_accessible :chip_count, :hand_id, :player_id
end

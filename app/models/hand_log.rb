class HandLog < ActiveRecord::Base
  attr_accessible :dealer_seat_id, :hand_id, :players_ids, :table_id
  
  serialize :players_ids
end

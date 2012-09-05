class Seat < ActiveRecord::Base
  attr_accessible :player_id, :table_id
  
  belongs_to :table
  has_one :player
end

class Seat < ActiveRecord::Base
  attr_accessible :player_id, :table_id
  
  belongs_to :table
  has_one :player
  
  def next_seat
    return Seat.find_by_id(self.id + 1)
  end
  
end

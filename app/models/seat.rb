class Seat < ActiveRecord::Base
  attr_accessible :player_id, :table_id
  
  belongs_to :table
  has_one :player
  
  def next_seat
    seat = self
    while(true)
      if seat == seat.table.seats.last            # Changes pointer to first seat if at last seat
        seat = self.table.seats.first             
      else  
        seat = Seat.find_by_id(seat.id + 1)       # Moves onto next seat
      end
      player = seat.player  
      player.reload
      logger.debug "Looking at player: #{player.name}"
      if player.in_game && player.in_round       # Checks if seat holds valid player
        logger.debug "FOUND NEXT PLAYER: #{player.name}"
        return seat
      end
    end
  end
end

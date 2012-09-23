class Pot < ActiveRecord::Base
  attr_accessible :player_ids, :round_id, :total
  
  serialize :player_ids
  
  belongs_to :round
  
  def players
    self.player_ids.map {|id| Player.find_by_id(id)}
    logger.debug "Players from pot: #{self.player_ids.map {|id| Player.find_by_id(id)}}"
  end
end

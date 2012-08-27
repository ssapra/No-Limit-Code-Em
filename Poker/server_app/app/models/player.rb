class Player < ActiveRecord::Base
  attr_accessible :game_id, :name, :player_key
  
  validates :name, :uniqueness => true 
   
end

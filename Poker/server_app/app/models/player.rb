class Player < ActiveRecord::Base
  attr_accessible :game_id, 
                  :name, 
                  :player_key, 
                  :hand, 
                  :stack, 
                  :bet, 
                  :action,
                  :in_game,
                  :in_round,
                  :turn, #don't use for now
                  :table_id
                  
  serialize :hand
  
  validates :name, :uniqueness => true 
   
  belongs_to :table
  belongs_to :seat
   
end

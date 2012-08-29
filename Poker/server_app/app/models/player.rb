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
                  :turn,
                  :table_id
                  
  serialize :hand
  
  validates :name, :uniqueness => true 
   
  belongs_to :table 
   
end

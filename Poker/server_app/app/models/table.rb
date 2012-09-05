class Table < ActiveRecord::Base
  attr_accessible :deck, :pot, :turn_id
  
  serialize :deck
  
  has_many :players
  has_many :seats, :dependent => :destroy
end

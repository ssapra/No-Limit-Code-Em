class Table < ActiveRecord::Base
  attr_accessible :deck, :pot
  
  serialize :deck
  
  has_many :players
end

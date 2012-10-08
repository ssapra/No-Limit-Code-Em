class Status < ActiveRecord::Base
  attr_accessible :game, 
                  :registration,
                  :waiting
end

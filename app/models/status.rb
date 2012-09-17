class Status < ActiveRecord::Base
  attr_accessible :game, 
                  # :play, 
                  :registration,
                  :waiting
                  # :tournament
end

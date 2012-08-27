class Request < ActiveRecord::Base
  attr_accessible :hostname, :name, :port_number
end

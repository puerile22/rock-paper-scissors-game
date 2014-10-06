module RPS
  class Tour < ActiveRecord::Base
    has_many :tourneys
  end
end
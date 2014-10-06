module RPS
  class Tourney < ActiveRecord::Base
    belongs_to :player
    belongs_to :tour
  end
end
module RPS
  class Player < ActiveRecord::Base
    has_many :tourneys
    validates :name, uniqueness:true, presence: true
  end
end
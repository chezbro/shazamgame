class Week < ActiveRecord::Base
  has_many :games
  accepts_nested_attributes_for  :games
end

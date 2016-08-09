class Selection < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  validates_presence_of :user_id
  validates_presence_of :game_id
  validates_presence_of :pref_pick_int
  validates_presence_of :pref_pick_team
  validates_presence_of :spread_pick_team
  
end



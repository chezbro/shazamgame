class Selection < ActiveRecord::Base

  belongs_to :user
  belongs_to :game

  validates_presence_of :user_id
  validates_presence_of :game_id
  validates_presence_of :pref_pick_int
  validates_presence_of :pref_pick_team
  validates_presence_of :spread_pick_team
  

  validates_uniqueness_of :pref_pick_int, :scope => [:user_id, :game_id]

  def user_pref_pick_uniqueness(user, week)
    # Selection.where(user_id: user).joins(:game). where(:games => { :week_id => week.id }).each do |s|
  end




  # def self.pref_picks(user)
  #   arr = []
  #   user.selections.each do |selection|
  #     if selection.game.week.id == Week.last.id
  #       arr << selection.game.pref_pick_int
  #     end
  #   end
  #   arr
  # end

end
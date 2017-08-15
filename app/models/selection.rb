class Selection < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  belongs_to :week

  validates_presence_of :user_id
  validates_presence_of :game_id
  validates_presence_of :pref_pick_int
  validates_presence_of :pref_pick_team
  validates_presence_of :spread_pick_team

  # before_save :pref_pick_unique
# private

# def pref_pick_unique(user)
#   Game.where(week_id: Week.last.id).each do |g|
#     g.selections.where(user_id: user).each do |s|
#       if pref_picks.include?(self.pref_pick_int)
#         errors.add(:base, 'Preference Pick Must Be Unique')
#       else
#         pref_picks << self.pref_pick_int
#         binding.pry
#       end
#     end
#   end
# end

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

class Week < ActiveRecord::Base
  has_many :games
  accepts_nested_attributes_for  :games

  validates_presence_of :home_team_id
  validates_presence_of :away_team_id
  validates_presence_of :game_selected_by_admin


  # def close_week_and_tally_points(week, user)
  #   w = Week.find(week)
  #   w.games.each do |game|
  #     game.selections.each do |selection|
  #       selection.points += user.cumulative_points
  #     end
  #   end
  # end  

end

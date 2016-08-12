class Week < ActiveRecord::Base
  has_many :games
  accepts_nested_attributes_for  :games


# This will run after all the Selections are given points or not.
  # def close_week_and_tally_points(week, user)
  #   w = Week.find(week)
  #   user.weekly_points = 0
  #   w.games.each do |game|
  #     game.selections.each do |selection|
  #       selection.points += user.cumulative_points
  #       selection.points += user.weekly_points
  #     end
  #   end
  # end  

# Write method to reset All Users Weekly Scores

end


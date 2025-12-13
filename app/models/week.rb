class Week < ActiveRecord::Base
  has_many :games
  has_many :scores
  has_many :points
  has_many :selections
  accepts_nested_attributes_for  :games

  # Add bowl_game flag
  after_initialize :set_defaults

  # Remove or modify this line
  # validates :bowl_game_name, uniqueness: true, if: :bowl_game?

  # Get available points as an array of integers
  def available_points_array
    if available_points.present?
      available_points.split(',').map(&:strip).map(&:to_i).sort.reverse
    else
      # Default to 1-13 if not set
      (1..13).to_a.reverse
    end
  end

  private

  def set_defaults
    self.bowl_game ||= false
    self.number_of_games ||= 13 if new_record?
    self.available_points ||= (1..13).to_a.join(',') if new_record? && available_points.blank?
  end

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

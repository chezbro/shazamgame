class Game < ActiveRecord::Base

  # after_save :winning_team

  belongs_to :week
  # belongs_to :user

  belongs_to :away_team, class_name: 'Team', foreign_key: 'away_team_id'
  belongs_to :home_team, class_name: 'Team', foreign_key: 'home_team_id'

  has_many :selections
  has_many :users

  # validates_presence_of :selections

  # accepts_nested_attributes_for  :selections

  # validates_presence_of :home_team_id
  # validates_presence_of :away_team_id
  # validates_presence_of :game_selected_by_admin

  # validates :bowl_game_name, presence: true, if: -> { week&.bowl_game? }

  validates :home_team_id, presence: true
  validates :away_team_id, presence: true
  validates :spread, presence: true

# def validate_pref_pick(params)
#   initial_arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
#   removed_arr = []
#   if initial_arr.include?(params)
#     removed_arr << params
#     initial_arr.delete(params)
#     return initial_arr
#   else
#   end
# end

def self.disable_picks
  Game.where(active: true).each do |game|
    game.active = false
    game.save!
  end
end

def set_team_that_won_straight_up
  if ( self.home_team_score > self.away_team_score )
    # Home Team Wins Straight Up
    self.home_team_won_straight_up = true
    self.team_that_won_straight_up  = self.home_team_id
    self.away_team_won_straight_up = false

  elsif ( self.home_team_score == self.away_team_score )

    # Push Game
    self.tie_game = true
    self.home_team_won_straight_up = false
    self.away_team_won_straight_up = false

  else
    # Away Team Wins Straight Up
    self.home_team_won_straight_up = false
    self.away_team_won_straight_up = true
    self.team_that_won_straight_up  = self.away_team_id
  end

end

def self.total_selections_for_pref_pick_team
  pref_pick_array = []
  last_week_selections = Selection.where(week_id: Week.last)
  last_week_selections.all.each do |each_selection|
      pref_pick_array.push([each_selection.pref_pick_team, each_selection.game_id])
    end
  pref_pick_hash = pref_pick_array.inject(Hash.new(0)) {|h,x| h[x]+=1;h}
  # these work now just need to look up team using the first value in the Hash.
  return pref_pick_hash
end

# def self.total_selections_for_spread_pick_team
#   spread_pick_team_array = []
#   last_week_selections = Selection.where(week_id: Week.last)
#   last_week_selections.all.each do |each_selection|
#       spread_pick_team_array.push(each_selection.spread_pick_team)
#     end
#   spread_pick_team_hash = spread_pick_team_array.inject(Hash.new(0)) {|h,x| h[x]+=1;h}
#   return spread_pick_team_hash
#   # these work now just need to look up team using the first value in the Hash.
# end


def which_team_covered_spread
  # Home Team Covered
  if ( (self.home_team_score + self.spread) > self.away_team_score )
    self.team_that_covered_spread = self.home_team.id

  elsif ( ( (self.home_team_score + self.spread ) - self.away_team_score ) == 0 )
    self.tie_game = true
    self.team_that_covered_spread = nil
  else
  # Away Team Covered
    self.team_that_covered_spread = self.away_team.id
  end
    self.save!
end

def game_reset
  User.all.each do |user|
    user.selections.each do |selection|
      if selection.game_id == self.id && selection.game.week.id == Week.last.id
        if selection.spread_pick_team == self.team_that_covered_spread
          user.weekly_points -= 7
          # user.total_weekly_points -= 7
          user.weekly_points_game_b -= 7
          user.cumulative_points -= 7
          user.save!
        end
        if selection.pref_pick_team == self.team_that_won_straight_up
          user.weekly_points -= selection.pref_pick_int
          # user.total_weekly_points -= selection.pref_pick_int
          user.weekly_points_game_a -= selection.pref_pick_int
          user.cumulative_points -= selection.pref_pick_int
          user.save!
        end
        if selection.game.tie_game == true
          user.weekly_points -= 7
          # user.total_weekly_points -= 7
          user.weekly_points_game_b -= 7
          user.cumulative_points -= 7
          user.save!
        end
      end
    end
  end
end

def tally_points
  Rails.logger.info "Tallying points for game #{id} (#{bowl_game_name if week&.bowl_game?})"
  
  User.all.each do |user|
    user.selections.each do |selection|
      if selection.game_id == self.id && selection.game.week.id == self.week.id
        Rails.logger.info "Processing selection for user #{user.id} (#{user.username})"
        
        # Set spread pick result (Game B)
        if selection.spread_pick_team == self.team_that_covered_spread
          user.weekly_points += 7
          user.weekly_points_game_b += 7
          user.cumulative_points += 7
          selection.correct_spread_pick = true
          selection.save!
          user.save!
          Rails.logger.info "User #{user.username} got spread pick correct"
        else
          selection.correct_spread_pick = false
          selection.save!
          Rails.logger.info "User #{user.username} got spread pick incorrect"
        end

        # Set preference pick result (Game A)
        if selection.pref_pick_team == self.team_that_won_straight_up
          user.weekly_points += selection.pref_pick_int
          user.weekly_points_game_a += selection.pref_pick_int
          user.cumulative_points += selection.pref_pick_int
          selection.correct_pref_pick = true
          selection.save!
          user.save!
          Rails.logger.info "User #{user.username} got pref pick correct"
        else
          selection.correct_pref_pick = false
          selection.save!
          Rails.logger.info "User #{user.username} got pref pick incorrect"
        end

        # Handle tie games
        if self.tie_game == true
          points_to_add = 7 + selection.pref_pick_int
          user.weekly_points += points_to_add
          user.cumulative_points += points_to_add
          user.weekly_points_game_a += selection.pref_pick_int
          user.weekly_points_game_b += 7
          selection.correct_spread_pick = true
          selection.save!
          user.save!
          Rails.logger.info "Game was a tie, user #{user.username} got points"
        end
      end
    end
  end
  
  # Mark game as scored
  self.has_game_been_scored = true
  self.save!
end

def reset_has_game_been_scored
    # We want the current user's selection on this Game
    self.has_game_been_scored = false
    self.save!
  end

def check_selection_and_tally_points
  Rails.logger.info "Starting to score game #{id}"
  self.set_team_that_won_straight_up
  self.save!
  Rails.logger.info "Team that won straight up: #{team_that_won_straight_up}"
  
  self.which_team_covered_spread
  self.save!
  Rails.logger.info "Team that covered spread: #{team_that_covered_spread}"
  
  self.reload
  self.active = false unless week.bowl_game?
  self.save!
  self.reload
  
  self.tally_points
  Rails.logger.info "Game #{id} scored: has_game_been_scored=#{has_game_been_scored}"
end



# Methods Not In Use

  # def close_active_games(games)
  #   # Turns all active Games false
  #   games.each do |g|
  #     g.active = false
  #     g.save!
  #     g.reload
  #   end
  # end

  # def won_game(u)
  #   if u.selections.first.game.home_team_id
  #   end
  # end

# def getSelections(user, game)
#   Selection.where(user_id: user).where(game_id: game)
# end

# def check_selection_and_tally_points(user)
#   # We want the current user's selection on this Game

#   user.selections.each do |selection|

#     # Get User Selection for Game
#     if selection.game_id == self.id

#       if selection.spread_pick_team.id == self.team_that_won_straight_up.id
#         selection.points = 7
#       else
#         selection.points = 0
#       end

#       if selection.pref_pick_team.id == self.team_that_covered_spread
#         selection.points = selection.pref_pick_int
#       else
#         selection.points = 0
#       end

#     end
#   end
# end

def display_name
  if week&.bowl_game? && bowl_game_name.present?
    bowl_game_name
  else
    "Week #{week.week_number} - #{home_team.region} vs #{away_team.region}"
  end
end

end

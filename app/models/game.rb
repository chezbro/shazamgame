class Game < ActiveRecord::Base
 
  # after_save :winning_team

  belongs_to :week
  # belongs_to :user

  belongs_to :away_team, class_name: 'Team', foreign_key: 'away_team_id'
  belongs_to :home_team, class_name: 'Team', foreign_key: 'home_team_id'
  
  has_many :selections
  has_many :users

  # validates_presence_of :home_team_id
  # validates_presence_of :away_team_id
  # validates_presence_of :game_selected_by_admin



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

def which_team_covered_spread
  # Home Team Covered
  if ( (self.home_team_score + self.spread) > self.away_team_score )
    self.team_that_covered_spread = self.home_team.id

  elsif ( (self.home_team_score - self.away_team_score ) == self.spread )
    self.tie_game = true
  # Away Team Covered
  else
    self.team_that_covered_spread = self.away_team.id
  end
    self.save!
end

def tally_points
  # points aren't being added correctly to User's points
  User.all.each do |user|
    user.selections.each do |selection|
      if selection.game_id == self.id
        if selection.spread_pick_team == self.team_that_won_straight_up
          user.weekly_points += 7
          user.cumulative_points += 7
          user.save!
        else       
          user.weekly_points += 0
          user.cumulative_points += 0
          user.save!
        end
        if selection.pref_pick_team == self.team_that_covered_spread
          user.weekly_points += selection.pref_pick_int
          user.cumulative_points += selection.pref_pick_int
          user.save!
        else
          user.weekly_points += 0
          user.cumulative_points += 0
          user.save!
        end
      end
    end
  end
end

def check_selection_and_tally_points
    # We want the current user's selection on this Game 
    self.set_team_that_won_straight_up
    self.save! 
    self.which_team_covered_spread
    self.save!
    self.reload    
    self.active = false
    self.save!
    self.reload    
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


end

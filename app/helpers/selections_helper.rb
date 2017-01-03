module SelectionsHelper

  # def selections_for_week(user, game)
  #   Selection.where(user_id: user).where(game_id: game)
  # end

  def pref_pick_integers
    [13]
    # [1,1,2, 2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13]
  end
    
  def selections_home_team_name(s)
    s.game.home_team.region + " " + s.game.home_team.name
  end

  def selections_away_team_name(s)
    s.game.away_team.region + " " + s.game.away_team.name
  end


  def selection_team(selection)
    Team.find_by_id(selection).try(:region)
  end

  
end

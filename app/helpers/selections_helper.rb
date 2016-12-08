module SelectionsHelper

  # def selections_for_week(user, game)
  #   Selection.where(user_id: user).where(game_id: game)
  # end

  def pref_pick_integers
    [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]
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

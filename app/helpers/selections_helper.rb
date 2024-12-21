module SelectionsHelper

  # def selections_for_week(user, game)
  #   Selection.where(user_id: user).where(game_id: game)
  # end

  def pref_pick_integers
    (1..13).to_a
  end

  def bowl_game_names
    [
      "Rose Bowl",
      "Sugar Bowl", 
      "Orange Bowl",
      "Cotton Bowl",
      "Fiesta Bowl",
      "Peach Bowl",
      "Citrus Bowl",
      "Outback Bowl",
      "Gator Bowl",
      "Holiday Bowl",
      "Sun Bowl",
      "Liberty Bowl",
      "Independence Bowl"
    ]
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

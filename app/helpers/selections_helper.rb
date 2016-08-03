module SelectionsHelper

  def home_team_name(s)
    s.game.home_team.region + " " + s.game.home_team.name
  end

  def away_team_name(s)
    s.game.away_team.region + " " + s.game.away_team.name
  end

end

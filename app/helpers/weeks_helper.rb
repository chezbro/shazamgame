module WeeksHelper

  def list_teams
    Team.all.map { |t| [t.region + " " + t.name, t.id] }.sort_by(&:first)
  end

  def spread_operator(game)
    if game.spread > 0
      return " +"
    elsif game.spread == 0
      return " "
    else 
      return " "
    end
  end

end

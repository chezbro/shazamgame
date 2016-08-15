module WeeksHelper

  def list_teams
    Team.all.map { |t| [t.region + " " + t.name, t.id] }.sort_by(&:first)
  end




  def current_week
    Week.last
  end
end

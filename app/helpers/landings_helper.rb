module LandingsHelper
  def users_selections_for_most_current_week
    current_user.selections.where(week_id: Week.last)
  end
end

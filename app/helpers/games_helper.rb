module GamesHelper
  def pref_pick(selection)
    Team.find(selection.pref_pick_team).region + " " + Team.find(selection.pref_pick_team).name 
  end

  def spread_pick(selection)
    Team.find(selection.spread_pick_team).region + " " + Team.find(selection.spread_pick_team).name
  end
end
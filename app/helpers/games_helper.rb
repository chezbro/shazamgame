module GamesHelper

  def pref_pick(selection)
    Team.find(selection.pref_pick_team).region + " " + Team.find(selection.pref_pick_team).name 
  end

  def spread_pick(selection)
    Team.find(selection.spread_pick_team).region + " " + Team.find(selection.spread_pick_team).name
  end

  def game_home_team_name(game)
    game.home_team.region + " " + game.home_team.name
  end

  def game_away_team_name(game)
    game.away_team.region + " " + game.away_team.name
  end

  def users_pref_pick_selection(game)
    current_user.selections.where(game_id: game).first.pref_pick_team if current_user.selections.where(game_id: game).present?
  end

  def users_pref_int_selection(game)
    current_user.selections.where(game_id: game).first.pref_pick_int if current_user.selections.where(game_id: game).present?
  end

  def users_spread_pick_selection(game)
    current_user.selections.where(game_id: game).first.spread_pick_team if current_user.selections.where(game_id: game).present?
  end


  def team_name(id)
    name = Team.find_by_id(id).try(:name)
    region = Team.find_by_id(id).try(:region)
    return region + " " + name if region.present? 
  end

  def pref_pick_integers
    [13,12,11,10,9,8,7,6,5,4,3,2,1]
  end

  def game_selection_link(game)
    game.selections.where(user_id:current_user).first
  end
end
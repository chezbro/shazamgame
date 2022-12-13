module SelectionsHelper

  # def selections_for_week(user, game)
  #   Selection.where(user_id: user).where(game_id: game)
  # end

  def pref_pick_integers
    # [13,12,11,10,9,8,7,6,5,4,3,2,1]
    [13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]
  #13
  end

  def bowl_game_names
    ["Bowl_Game_1", "Bowl_Game_2", "Bowl_Game_3", "Bowl_Game_4", "Bowl_Game_5", "Bowl_Game_6", "Bowl_Game_7", "Bowl_Game_8", "Bowl_Game_9","Bowl_Game_10", "Bowl_Game_11", "Bowl_Game_12", "Bowl_Game_13", "Bowl_Game_14", "Bowl_Game_15", "Bowl_Game_16", "Bowl_Game_17", "Bowl_Game_18", "Bowl_Game_19", "Bowl_Game_20", "Bowl_Game_21", "Bowl_Game_22", "Bowl_Game_23", "Bowl_Game_24", "Bowl_Game_25", "Bowl_Game_26" ]
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

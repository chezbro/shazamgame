ActiveAdmin.register Selection do
  permit_params :game_id, :user_id, :pref_pick_int, :pref_pick_team, :spread_pick_team, :created_at, :updated_at


  index do
    column :game_id do |selection|
      game = selection.game if selection.game.present?
      full_game_name(game) if game != nil
  end 
    column :user_id do |selection|
      selection.user.name + " (#{selection.user.username})"
    end
    column :pref_pick_team do |selection|
      team = Team.find(selection.pref_pick_team)
      team.region 
    end
    column :pref_pick_int
    column :spread_pick_team do |selection|
      team = Team.find(selection.spread_pick_team)
      team.region 
    end
    actions
  end
end

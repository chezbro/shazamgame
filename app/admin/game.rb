ActiveAdmin.register Game do
  permit_params :points, :is_home_team, :spread, :home_team_id, :away_team_id, :home_team_pref_pick, :away_team_pref_pick, :home_team_spread_pick, :away_team_spread_pick, :home_team_covered_spread, :away_team_covered_spread, :tie_game, :game_selected_by_admin

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end

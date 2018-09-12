ActiveAdmin.register User do
  permit_params :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :name, :nickname, :name, :weekly_points, :cumulative_points, :fav_teams

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
  index do

    column :name do |user|
      user.name + " (#{user.username})"
    end

    column :weekly_points do |user|
      user.weekly_points
    end

    column :cumulative_points do |user|
      user.cumulative_points
    end

    column :favorite_teams do |user|
      user.fav_teams
    end
    actions
  end

form do |f|
  f.inputs do
    f.input :name, :input_html => {:readonly =>
true}
    f.input :weekly_points, label: "Weekly Points"
    f.input :cumulative_points, label: "Cumulative Points"
    f.input :fav_teams, label: "Favorite Teams"
    f.submit
  end
end


end

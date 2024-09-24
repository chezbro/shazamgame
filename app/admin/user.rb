ActiveAdmin.register User do
  permit_params :email, :name, :nickname, :username, :weekly_points, :cumulative_points

  # Remove or comment out the existing index block
  # index do
  #   ...
  # end

  filter :email
  filter :username
  filter :name
  filter :nickname
  filter :weekly_points
  filter :cumulative_points
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :name
    column :nickname
    column :weekly_points
    column :cumulative_points
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :name
      f.input :nickname
      f.input :username
      f.input :weekly_points
      f.input :cumulative_points
    end
    f.actions
  end
end

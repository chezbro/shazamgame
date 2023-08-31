class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :address, :string
    add_column :users, :fav_teams, :string
    add_column :users, :cell_phone_number, :string
  end
end

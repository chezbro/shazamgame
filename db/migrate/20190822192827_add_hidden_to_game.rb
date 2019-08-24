class AddHiddenToGame < ActiveRecord::Migration
  def change
    add_column :games, :hidden, :boolean, default: false
  end
end

class AddHiddenToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :hidden, :boolean, default: false
  end
end

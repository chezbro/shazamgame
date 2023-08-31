class AddActiveToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :active, :boolean
  end
end

class AddGameIsActiveToGames < ActiveRecord::Migration
  def change
    add_column :games, :game_is_active, :boolean
  end
end

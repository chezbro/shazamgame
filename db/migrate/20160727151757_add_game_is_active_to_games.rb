class AddGameIsActiveToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :game_is_active, :boolean
  end
end

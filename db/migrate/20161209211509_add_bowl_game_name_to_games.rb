class AddBowlGameNameToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :bowl_game_name, :string
  end
end

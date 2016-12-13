class AddBowlGameNameToGames < ActiveRecord::Migration
  def change
    add_column :games, :bowl_game_name, :string
  end
end

class AddHomeTeamSpreadToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :home_team_spread, :integer
  end
end

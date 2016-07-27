class AddHomeTeamSpreadToGames < ActiveRecord::Migration
  def change
    add_column :games, :home_team_spread, :integer
  end
end

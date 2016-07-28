class AddScoresToGames < ActiveRecord::Migration
  def change
    add_column :games, :home_team_score, :integer
    add_column :games, :away_team_score, :integer
  end
end

class AddFieldsToGames < ActiveRecord::Migration
  def change
    add_column :games, :home_team_won_straight_up, :boolean
    add_column :games, :away_team_won_straight_up, :boolean
    add_column :games, :team_that_won_straight_up, :integer
  end
end

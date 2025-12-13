class AddNumberOfGamesAndAvailablePointsToWeeks < ActiveRecord::Migration[5.1]
  def change
    add_column :weeks, :number_of_games, :integer, default: 13
    add_column :weeks, :available_points, :string
  end
end


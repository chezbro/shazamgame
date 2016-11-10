class AddGameAbToPoints < ActiveRecord::Migration
  def change
    add_column :points, :weekly_points_game_a, :integer, :default => 0
    add_column :points, :weekly_points_game_b, :integer, :default => 0
  end
end

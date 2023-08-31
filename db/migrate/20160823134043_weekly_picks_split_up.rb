class WeeklyPicksSplitUp < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :weekly_points_game_a, :integer
    add_column :users, :weekly_points_game_b, :integer
  end
end

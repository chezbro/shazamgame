class WeeklyGameAbDefaultZero < ActiveRecord::Migration
  def change
     change_column :users, :weekly_points_game_a, :integer, :default => 0
     change_column :users, :weekly_points_game_b, :integer, :default => 0
  end
end

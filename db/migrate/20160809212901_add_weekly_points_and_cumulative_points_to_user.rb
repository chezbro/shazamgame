class AddWeeklyPointsAndCumulativePointsToUser < ActiveRecord::Migration
  def change
    add_column :users, :weekly_points, :integer
    add_column :users, :cumulative_points, :integer
  end
end

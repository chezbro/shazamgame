class AddWeeklyPointsAndCumulativePointsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :weekly_points, :integer
    add_column :users, :cumulative_points, :integer
  end
end

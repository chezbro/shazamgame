class AddTotalWeeklyPointsToUser < ActiveRecord::Migration
  def change
    add_column :users, :total_weekly_points, :integer
  end
end

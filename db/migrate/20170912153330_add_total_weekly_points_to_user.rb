class AddTotalWeeklyPointsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :total_weekly_points, :integer
  end
end

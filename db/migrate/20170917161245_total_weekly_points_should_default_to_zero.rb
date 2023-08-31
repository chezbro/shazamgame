class TotalWeeklyPointsShouldDefaultToZero < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :total_weekly_points, :integer, :default => 0
  end
end

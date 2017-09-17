class TotalWeeklyPointsShouldDefaultToZero < ActiveRecord::Migration
  def change
    change_column :users, :total_weekly_points, :integer, :default => 0
  end
end

class MakePointFieldsStartAtZero < ActiveRecord::Migration
  def change
    change_column :users, :weekly_points, :integer, :default => 0
    change_column :users, :cumulative_points, :integer, :default => 0
  end
end

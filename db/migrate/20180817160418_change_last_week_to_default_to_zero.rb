class ChangeLastWeekToDefaultToZero < ActiveRecord::Migration
  def change
    change_column :users, :last_week_score, :integer, :default => 0
  end
end

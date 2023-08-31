class ChangeLastWeekToDefaultToZero < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :last_week_score, :integer, :default => 0
  end
end

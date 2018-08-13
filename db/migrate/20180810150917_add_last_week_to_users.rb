class AddLastWeekToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_week_score, :integer
  end
end

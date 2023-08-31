class AddLastWeekToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_week_score, :integer
  end
end

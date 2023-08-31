class CreatePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :points do |t|
      t.integer :user_id
      t.integer :week_id
      t.integer :cumulative_points, :integer, :default => 0
      t.integer :weekly_points, :integer, :default => 0
    end
  end
end

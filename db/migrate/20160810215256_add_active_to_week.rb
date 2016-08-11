class AddActiveToWeek < ActiveRecord::Migration
  def change
    add_column :weeks, :active, :boolean
  end
end

class AddActiveToWeek < ActiveRecord::Migration[5.1]
  def change
    add_column :weeks, :active, :boolean
  end
end

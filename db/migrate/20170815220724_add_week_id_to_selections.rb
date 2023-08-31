class AddWeekIdToSelections < ActiveRecord::Migration[5.1]
  def change
    add_column :selections, :week_id, :integer
  end
end

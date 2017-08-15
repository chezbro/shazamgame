class AddWeekIdToSelections < ActiveRecord::Migration
  def change
    add_column :selections, :week_id, :integer
  end
end

class AddFieldsToSelections < ActiveRecord::Migration
  def change
    add_column :selections, :points, :integer
    add_column :selections, :pref_pick_int, :integer
    add_column :selections, :pref_pick_str, :string
    add_column :selections, :spread_pick, :integer
  end
end

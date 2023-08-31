class AddCorrectTypesToSelections < ActiveRecord::Migration[5.1]
  def change
    add_column :selections, :correct_spread_pick, :boolean, :default => false
    add_column :selections, :correct_pref_pick, :boolean, :default => false
  end
end

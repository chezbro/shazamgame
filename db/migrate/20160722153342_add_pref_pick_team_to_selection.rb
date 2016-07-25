class AddPrefPickTeamToSelection < ActiveRecord::Migration
  def change
    add_column :selections, :pref_pick_team, :integer
  end
end

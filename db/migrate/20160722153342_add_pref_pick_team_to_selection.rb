class AddPrefPickTeamToSelection < ActiveRecord::Migration[5.1]
  def change
    add_column :selections, :pref_pick_team, :integer
  end
end

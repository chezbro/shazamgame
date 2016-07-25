class EditSelectionsFields < ActiveRecord::Migration
  def change
    add_column :selections, :spread_pick_team, :int
  end
end

class EditSelectionsFields < ActiveRecord::Migration[5.1]
  def change
    add_column :selections, :spread_pick_team, :int
  end
end

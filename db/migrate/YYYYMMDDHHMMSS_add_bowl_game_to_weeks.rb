class AddBowlGameToWeeks < ActiveRecord::Migration[5.1]
  def change
    add_column :weeks, :bowl_game, :boolean, default: false
  end
end 
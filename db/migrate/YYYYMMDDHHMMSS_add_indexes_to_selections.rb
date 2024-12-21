class AddIndexesToSelections < ActiveRecord::Migration[6.1]
  def change
    add_index :selections, [:user_id, :game_id]
    add_index :selections, [:game_id, :week_id]
    add_index :games, :week_id
  end
end 
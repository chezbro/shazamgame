class AddHasGameBeenScored < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :has_game_been_scored, :boolean
  end
end

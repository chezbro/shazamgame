class AddHasGameBeenScored < ActiveRecord::Migration
  def change
    add_column :games, :has_game_been_scored, :boolean
  end
end

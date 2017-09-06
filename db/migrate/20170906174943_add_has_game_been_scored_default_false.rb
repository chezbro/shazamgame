class AddHasGameBeenScoredDefaultFalse < ActiveRecord::Migration
  def change
    change_column :games, :has_game_been_scored, :boolean, :default => false
  end
end

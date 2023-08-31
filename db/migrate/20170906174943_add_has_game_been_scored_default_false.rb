class AddHasGameBeenScoredDefaultFalse < ActiveRecord::Migration[5.1]
  def change
    change_column :games, :has_game_been_scored, :boolean, :default => false
  end
end

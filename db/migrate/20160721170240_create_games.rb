class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :week, index: true
      t.references :user, index: true
      t.integer :points
      t.boolean :is_home_team
      t.integer :spread
      t.integer :home_team_id
      t.integer :away_team_id
      t.integer :home_team_pref_pick
      t.integer :away_team_pref_pick
      t.boolean :home_team_spread_pick
      t.boolean :away_team_spread_pick
      t.boolean :home_team_covered_spread
      t.boolean :away_team_covered_spread
      t.boolean :tie_game
      t.boolean :game_selected_by_admin

      t.timestamps
    end
  end
end

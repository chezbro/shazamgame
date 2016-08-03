class AddFieldToGame < ActiveRecord::Migration
  def change
    add_column :games, :team_that_covered_spread, :integer
  end
end

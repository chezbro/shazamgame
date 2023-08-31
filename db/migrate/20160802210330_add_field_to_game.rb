class AddFieldToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :team_that_covered_spread, :integer
  end
end

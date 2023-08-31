class AddScoreModel < ActiveRecord::Migration[5.1]
  def change
    create_table :scores do |t|
      t.integer :week_id
      t.integer :user_id
      t.integer :game_a
      t.integer :game_b
      t.integer :points_for_week

      t.timestamps
    end 
  end
end

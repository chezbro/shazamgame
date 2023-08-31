class CreateSelections < ActiveRecord::Migration[5.1]
  def change
    create_table :selections do |t|
      t.integer :game_id
      t.integer :user_id
      t.boolean :correct
      t.boolean :admin

      t.timestamps null: false
    end
  end
end

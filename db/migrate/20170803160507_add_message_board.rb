class AddMessageBoard < ActiveRecord::Migration
  def change
    drop_table :messages
    create_table :messages do |t|
      t.integer :user_id
      t.string :body
      t.timestamps
    end
  end
end

class AddMessageBoard < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.string :body
      t.timestamps
    end
  end
end

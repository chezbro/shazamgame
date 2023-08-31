class CreateAnnouncements < ActiveRecord::Migration[5.1]
  def change
    create_table :announcements do |t|
      t.text :body
      t.text :heading
      t.string :type

      t.timestamps null: false
    end
  end
end

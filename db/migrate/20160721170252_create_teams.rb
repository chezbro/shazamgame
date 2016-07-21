class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :tid
      t.integer :cid
      t.integer :did
      t.string :region
      t.string :name
      t.string :abbrev
      t.string :city
      t.string :state
      t.float :latitude

      t.timestamps
    end
  end
end

class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.string :week_number
      t.string :year
      t.datetime :year_in_datetime

      t.timestamps
    end
  end
end

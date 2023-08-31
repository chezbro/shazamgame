class AddSavedToAnnouncement < ActiveRecord::Migration[5.1]
  def change
    add_column :announcements, :saved, :boolean
  end
end

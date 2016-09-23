class AddSavedToAnnouncement < ActiveRecord::Migration
  def change
    add_column :announcements, :saved, :boolean
  end
end

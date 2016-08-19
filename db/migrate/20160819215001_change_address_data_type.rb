class ChangeAddressDataType < ActiveRecord::Migration
  def change
    change_column :users, :address, :text
  end
end

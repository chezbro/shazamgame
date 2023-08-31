class ChangeAddressDataType < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :address, :text
  end
end

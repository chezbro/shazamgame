class ChangeSpreadToDecimal < ActiveRecord::Migration[5.1]
  def change
    change_column :games, :spread, :float
  end
end

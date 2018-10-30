class AddCorrectTypesToSelectionsRemoveDefaults < ActiveRecord::Migration
  def change
    change_column_default :selections, :correct_pref_pick, nil
    change_column_default :selections, :correct_spread_pick, nil
  end
end

class AddUniqueIndexToTeamsRegionAndName < ActiveRecord::Migration[6.1]
  def up
    # First, update any games that reference duplicate teams to point to the first occurrence
    # This prevents foreign key issues when we delete duplicates
    duplicate_groups = execute(<<-SQL
      SELECT region, name, array_agg(id ORDER BY id) as ids
      FROM teams
      GROUP BY region, name
      HAVING COUNT(*) > 1
    SQL
    ).to_a

    duplicate_groups.each do |row|
      ids = row['ids'].gsub(/[{}]/, '').split(',').map(&:to_i).sort
      keep_id = ids.first
      ids_to_delete = ids[1..-1]
      
      # Update games that reference duplicate teams to point to the kept team
      ids_to_delete.each do |duplicate_id|
        execute("UPDATE games SET home_team_id = #{keep_id} WHERE home_team_id = #{duplicate_id}")
        execute("UPDATE games SET away_team_id = #{keep_id} WHERE away_team_id = #{duplicate_id}")
      end
      
      # Update selections (user picks) that reference duplicate teams to point to the kept team
      # This preserves all user selections and picks
      ids_to_delete.each do |duplicate_id|
        execute("UPDATE selections SET pref_pick_team = #{keep_id} WHERE pref_pick_team = #{duplicate_id}")
        execute("UPDATE selections SET spread_pick_team = #{keep_id} WHERE spread_pick_team = #{duplicate_id}")
      end
      
      # Now safe to delete the duplicates
      execute("DELETE FROM teams WHERE id IN (#{ids_to_delete.join(',')})") if ids_to_delete.any?
    end

    # Now add the unique index
    add_index :teams, [:region, :name], unique: true, name: 'index_teams_on_region_and_name'
  end

  def down
    remove_index :teams, name: 'index_teams_on_region_and_name'
  end
end

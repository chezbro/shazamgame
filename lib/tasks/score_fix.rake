namespace :fix do
  desc "Fix all weekly and cumulative scores based on actual selections (DRY RUN)"
  task fix_scores_dry_run: :environment do
    puts "=" * 80
    puts "SCORE FIX DRY RUN"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "This is a DRY RUN - no changes will be made"
    puts "=" * 80

    total_fixes = 0
    total_users = User.count
    
    User.find_each do |user|
      puts "Analyzing user: #{user.username} (ID: #{user.id})"
      
      # Calculate what the scores should be based on selections
      calculated_weekly_game_a = 0
      calculated_weekly_game_b = 0
      calculated_cumulative = 0
      
      user.selections.includes(:game).each do |selection|
        game = selection.game
        
        # Only count points for games that have been scored
        next unless game.has_game_been_scored?
        
        # Calculate Game A points (preference picks)
        if selection.correct_pref_pick == true
          calculated_weekly_game_a += selection.pref_pick_int
          calculated_cumulative += selection.pref_pick_int
        end
        
        # Calculate Game B points (spread picks)
        if selection.correct_spread_pick == true
          calculated_weekly_game_b += 7
          calculated_cumulative += 7
        end
      end
      
      calculated_weekly_total = calculated_weekly_game_a + calculated_weekly_game_b
      
      # Check what changes would be made
      changes = []
      if user.weekly_points_game_a != calculated_weekly_game_a
        changes << "weekly_points_game_a: #{user.weekly_points_game_a} → #{calculated_weekly_game_a}"
      end
      
      if user.weekly_points_game_b != calculated_weekly_game_b
        changes << "weekly_points_game_b: #{user.weekly_points_game_b} → #{calculated_weekly_game_b}"
      end
      
      if user.weekly_points != calculated_weekly_total
        changes << "weekly_points: #{user.weekly_points} → #{calculated_weekly_total}"
      end
      
      if user.cumulative_points != calculated_cumulative
        changes << "cumulative_points: #{user.cumulative_points} → #{calculated_cumulative}"
      end
      
      if changes.any?
        puts "  📝 Would fix:"
        changes.each { |change| puts "    - #{change}" }
        total_fixes += changes.count
      else
        puts "  ✅ No changes needed"
      end
      
      puts
    end
    
    puts "=" * 80
    puts "DRY RUN SUMMARY"
    puts "=" * 80
    puts "Total users analyzed: #{total_users}"
    puts "Total fixes that would be made: #{total_fixes}"
    puts
    puts "To apply these fixes, run: rake fix:fix_scores"
    puts "=" * 80
  end

  desc "Fix all weekly and cumulative scores based on actual selections"
  task fix_scores: :environment do
    puts "=" * 80
    puts "SCORE FIX - APPLYING CHANGES"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "⚠️  THIS WILL MODIFY DATABASE RECORDS ⚠️"
    puts "=" * 80
    
    # Confirm before proceeding
    print "Are you sure you want to proceed? Type 'yes' to continue: "
    confirmation = STDIN.gets.chomp
    
    unless confirmation.downcase == 'yes'
      puts "Operation cancelled."
      exit 0
    end

    total_fixes = 0
    total_users = User.count
    
    User.find_each do |user|
      puts "Fixing user: #{user.username} (ID: #{user.id})"
      
      # Calculate what the scores should be based on selections
      calculated_weekly_game_a = 0
      calculated_weekly_game_b = 0
      calculated_cumulative = 0
      
      user.selections.includes(:game).each do |selection|
        game = selection.game
        
        # Only count points for games that have been scored
        next unless game.has_game_been_scored?
        
        # Calculate Game A points (preference picks)
        if selection.correct_pref_pick == true
          calculated_weekly_game_a += selection.pref_pick_int
          calculated_cumulative += selection.pref_pick_int
        end
        
        # Calculate Game B points (spread picks)
        if selection.correct_spread_pick == true
          calculated_weekly_game_b += 7
          calculated_cumulative += 7
        end
      end
      
      calculated_weekly_total = calculated_weekly_game_a + calculated_weekly_game_b
      
      # Apply the fixes
      changes_made = []
      
      if user.weekly_points_game_a != calculated_weekly_game_a
        old_value = user.weekly_points_game_a
        user.weekly_points_game_a = calculated_weekly_game_a
        changes_made << "weekly_points_game_a: #{old_value} → #{calculated_weekly_game_a}"
      end
      
      if user.weekly_points_game_b != calculated_weekly_game_b
        old_value = user.weekly_points_game_b
        user.weekly_points_game_b = calculated_weekly_game_b
        changes_made << "weekly_points_game_b: #{old_value} → #{calculated_weekly_game_b}"
      end
      
      if user.weekly_points != calculated_weekly_total
        old_value = user.weekly_points
        user.weekly_points = calculated_weekly_total
        changes_made << "weekly_points: #{old_value} → #{calculated_weekly_total}"
      end
      
      if user.cumulative_points != calculated_cumulative
        old_value = user.cumulative_points
        user.cumulative_points = calculated_cumulative
        changes_made << "cumulative_points: #{old_value} → #{calculated_cumulative}"
      end
      
      if changes_made.any?
        user.save!
        puts "  ✅ Fixed:"
        changes_made.each { |change| puts "    - #{change}" }
        total_fixes += changes_made.count
      else
        puts "  ✅ No changes needed"
      end
      
      puts
    end
    
    puts "=" * 80
    puts "FIX SUMMARY"
    puts "=" * 80
    puts "Total users processed: #{total_users}"
    puts "Total fixes applied: #{total_fixes}"
    puts
    puts "✅ All scores have been corrected!"
    puts "Run 'rake verification:verify_scores' to confirm all scores are now correct."
    puts "=" * 80
  end

  desc "Backup current user scores to a file before making changes"
  task backup_scores: :environment do
    backup_file = "user_scores_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
    backup_path = Rails.root.join(backup_file)
    
    puts "Creating backup of current user scores..."
    
    backup_data = {
      timestamp: Time.current,
      environment: Rails.env,
      users: []
    }
    
    User.find_each do |user|
      backup_data[:users] << {
        id: user.id,
        username: user.username,
        email: user.email,
        weekly_points: user.weekly_points,
        weekly_points_game_a: user.weekly_points_game_a,
        weekly_points_game_b: user.weekly_points_game_b,
        cumulative_points: user.cumulative_points,
        last_week_score: user.last_week_score
      }
    end
    
    File.write(backup_path, JSON.pretty_generate(backup_data))
    
    puts "✅ Backup created: #{backup_path}"
    puts "Backup contains #{backup_data[:users].count} users"
  end
end

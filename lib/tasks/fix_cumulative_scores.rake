namespace :fix do
  desc "Fix cumulative scores to match actual total season points"
  task cumulative_scores: :environment do
    puts "=" * 80
    puts "FIX CUMULATIVE SCORES"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_updated = 0
    total_fixes = 0
    
    puts "Total users in system: #{total_users}"
    puts

    # Check if there are any scored games
    scored_games = Game.where(has_game_been_scored: true)
    if scored_games.empty?
      puts "❌ No scored games found. Cannot fix cumulative scores."
      puts "   Please score at least one game first."
      exit 1
    end

    puts "Found #{scored_games.count} scored games across all weeks"
    puts

    # Create backup before making changes
    backup_file = "cumulative_scores_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
    backup_path = Rails.root.join(backup_file)
    
    backup_data = {
      timestamp: Time.current,
      environment: Rails.env,
      users: []
    }
    
    puts "STEP 1: CREATING BACKUP"
    puts "-" * 40
    
    User.find_each do |user|
      backup_data[:users] << {
        id: user.id,
        username: user.username,
        email: user.email,
        cumulative_points: user.cumulative_points,
        weekly_points: user.weekly_points,
        weekly_points_game_a: user.weekly_points_game_a,
        weekly_points_game_b: user.weekly_points_game_b,
        last_week_score: user.last_week_score
      }
    end
    
    File.write(backup_path, JSON.pretty_generate(backup_data))
    puts "✅ Backup created: #{backup_file}"
    puts
    
    puts "STEP 2: FIXING CUMULATIVE SCORES"
    puts "-" * 40

    User.find_each do |user|
      puts "Processing user: #{user.username}"
      
      # Calculate what cumulative points should be based on all scored games
      calculated_cumulative = 0
      game_breakdown = []
      
      user.selections.includes(:game).each do |selection|
        game = selection.game
        
        # Only count points for games that have been scored
        next unless game.has_game_been_scored?
        
        game_a_points = 0
        game_b_points = 0
        
        # Calculate Game A points (preference picks)
        if selection.correct_pref_pick == true
          game_a_points = selection.pref_pick_int
        end
        
        # Calculate Game B points (spread picks)
        if selection.correct_spread_pick == true
          game_b_points = 7
        end
        
        total_game_points = game_a_points + game_b_points
        calculated_cumulative += total_game_points
        
        if total_game_points > 0
          game_breakdown << "Week #{game.week.week_number} Game #{game.id}: +#{total_game_points}"
        end
      end
      
      old_cumulative = user.cumulative_points
      
      # Only update if there's a discrepancy
      if user.cumulative_points != calculated_cumulative
        user.cumulative_points = calculated_cumulative
        
        if user.save!
          users_updated += 1
          discrepancy = calculated_cumulative - old_cumulative
          total_fixes += discrepancy.abs
          
          puts "  ✅ FIXED: #{old_cumulative} → #{calculated_cumulative} (#{discrepancy > 0 ? '+' : ''}#{discrepancy})"
          
          if game_breakdown.any?
            puts "    Points from: #{game_breakdown.join(', ')}"
          end
        else
          puts "  ❌ FAILED to save: #{user.errors.full_messages.join(', ')}"
        end
      else
        puts "  ✅ Already correct: #{user.cumulative_points}"
      end
      
      puts
    end
    
    puts "FIX SUMMARY:"
    puts "-" * 40
    puts "Total users processed: #{total_users}"
    puts "Users updated: #{users_updated}"
    puts "Users already correct: #{total_users - users_updated}"
    puts "Total point corrections: #{total_fixes}"
    puts

    if users_updated == 0
      puts "🎉 ALL CUMULATIVE SCORES WERE ALREADY CORRECT!"
    else
      puts "🎉 SUCCESSFULLY FIXED #{users_updated} USERS!"
      puts "✅ All cumulative scores now reflect actual total season points."
    end
    
    puts
    puts "STEP 3: FINAL VERIFICATION"
    puts "-" * 40
    
    # Quick verification
    verification_errors = 0
    User.find_each do |user|
      calculated_cumulative = 0
      
      user.selections.includes(:game).each do |selection|
        game = selection.game
        next unless game.has_game_been_scored?
        
        if selection.correct_pref_pick == true
          calculated_cumulative += selection.pref_pick_int
        end
        
        if selection.correct_spread_pick == true
          calculated_cumulative += 7
        end
      end
      
      if user.cumulative_points != calculated_cumulative
        verification_errors += 1
        puts "❌ #{user.username}: Still incorrect (stored: #{user.cumulative_points}, calculated: #{calculated_cumulative})"
      end
    end
    
    if verification_errors == 0
      puts "✅ VERIFICATION PASSED: All cumulative scores are now correct!"
    else
      puts "❌ VERIFICATION FAILED: #{verification_errors} users still have incorrect scores."
    end
    
    puts
    puts "=" * 80
    puts "FIX COMPLETE"
    puts "=" * 80
  end
end

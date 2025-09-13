namespace :fix do
  desc "Fix ALL point totals - weekly, cumulative, Game A, Game B - to be completely accurate"
  task all_points: :environment do
    puts "=" * 80
    puts "FIX ALL POINT TOTALS"
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
      puts "❌ No scored games found. Cannot fix point totals."
      puts "   Please score at least one game first."
      exit 1
    end

    puts "Found #{scored_games.count} scored games across all weeks"
    puts

    # Create backup before making changes
    backup_file = "all_points_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
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
        weekly_points: user.weekly_points,
        weekly_points_game_a: user.weekly_points_game_a,
        weekly_points_game_b: user.weekly_points_game_b,
        cumulative_points: user.cumulative_points,
        last_week_score: user.last_week_score
      }
    end
    
    File.write(backup_path, JSON.pretty_generate(backup_data))
    puts "✅ Backup created: #{backup_file}"
    puts
    
    puts "STEP 2: FIXING ALL POINT TOTALS"
    puts "-" * 40

    User.find_each do |user|
      puts "Processing user: #{user.username}"
      
      # Calculate what ALL scores should be based on selections
      calculated_weekly_game_a = 0
      calculated_weekly_game_b = 0
      calculated_weekly_total = 0
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
          calculated_weekly_game_a += game_a_points
          calculated_cumulative += game_a_points
        end
        
        # Calculate Game B points (spread picks)
        if selection.correct_spread_pick == true
          game_b_points = 7
          calculated_weekly_game_b += game_b_points
          calculated_cumulative += game_b_points
        end
        
        total_game_points = game_a_points + game_b_points
        calculated_weekly_total += total_game_points
        
        if total_game_points > 0
          game_breakdown << "Week #{game.week.week_number}: +#{total_game_points}"
        end
      end
      
      # Store old values
      old_weekly_game_a = user.weekly_points_game_a
      old_weekly_game_b = user.weekly_points_game_b
      old_weekly_total = user.weekly_points
      old_cumulative = user.cumulative_points
      
      # Check if any changes are needed
      changes_needed = []
      total_changes = 0
      
      if user.weekly_points_game_a != calculated_weekly_game_a
        changes_needed << "Game A: #{old_weekly_game_a} → #{calculated_weekly_game_a}"
        user.weekly_points_game_a = calculated_weekly_game_a
        total_changes += (calculated_weekly_game_a - old_weekly_game_a).abs
      end
      
      if user.weekly_points_game_b != calculated_weekly_game_b
        changes_needed << "Game B: #{old_weekly_game_b} → #{calculated_weekly_game_b}"
        user.weekly_points_game_b = calculated_weekly_game_b
        total_changes += (calculated_weekly_game_b - old_weekly_game_b).abs
      end
      
      if user.weekly_points != calculated_weekly_total
        changes_needed << "Weekly: #{old_weekly_total} → #{calculated_weekly_total}"
        user.weekly_points = calculated_weekly_total
        total_changes += (calculated_weekly_total - old_weekly_total).abs
      end
      
      if user.cumulative_points != calculated_cumulative
        changes_needed << "Cumulative: #{old_cumulative} → #{calculated_cumulative}"
        user.cumulative_points = calculated_cumulative
        total_changes += (calculated_cumulative - old_cumulative).abs
      end
      
      if changes_needed.any?
        if user.save!
          users_updated += 1
          total_fixes += total_changes
          
          puts "  ✅ FIXED #{changes_needed.count} fields:"
          changes_needed.each { |change| puts "    - #{change}" }
          
          if game_breakdown.any?
            puts "    Points from: #{game_breakdown.join(', ')}"
          end
        else
          puts "  ❌ FAILED to save: #{user.errors.full_messages.join(', ')}"
        end
      else
        puts "  ✅ Already correct"
      end
      
      puts
    end
    
    puts "FIX SUMMARY:"
    puts "-" * 40
    puts "Total users processed: #{total_users}"
    puts "Users updated: #{users_updated}"
    puts "Users already correct: #{total_users - users_updated}"
    puts "Total field corrections: #{total_fixes}"
    puts

    if users_updated == 0
      puts "🎉 ALL POINT TOTALS WERE ALREADY CORRECT!"
    else
      puts "🎉 SUCCESSFULLY FIXED #{users_updated} USERS!"
      puts "✅ All point totals now accurately reflect actual game results."
    end
    
    puts
    puts "STEP 3: FINAL VERIFICATION"
    puts "-" * 40
    
    # Quick verification
    verification_errors = 0
    User.find_each do |user|
      calculated_weekly_game_a = 0
      calculated_weekly_game_b = 0
      calculated_cumulative = 0
      
      user.selections.includes(:game).each do |selection|
        game = selection.game
        next unless game.has_game_been_scored?
        
        if selection.correct_pref_pick == true
          calculated_weekly_game_a += selection.pref_pick_int
          calculated_cumulative += selection.pref_pick_int
        end
        
        if selection.correct_spread_pick == true
          calculated_weekly_game_b += 7
          calculated_cumulative += 7
        end
      end
      
      calculated_weekly_total = calculated_weekly_game_a + calculated_weekly_game_b
      
      if user.weekly_points_game_a != calculated_weekly_game_a ||
         user.weekly_points_game_b != calculated_weekly_game_b ||
         user.weekly_points != calculated_weekly_total ||
         user.cumulative_points != calculated_cumulative
        verification_errors += 1
        puts "❌ #{user.username}: Still has errors"
      end
    end
    
    if verification_errors == 0
      puts "✅ VERIFICATION PASSED: All point totals are now correct!"
    else
      puts "❌ VERIFICATION FAILED: #{verification_errors} users still have incorrect scores."
    end
    
    puts
    puts "=" * 80
    puts "FIX COMPLETE"
    puts "=" * 80
  end
end

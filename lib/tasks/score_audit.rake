namespace :audit do
  desc "Complete score audit: verify, backup, and fix all scores in one command"
  task scores: :environment do
    puts "=" * 80
    puts "COMPLETE SCORE AUDIT"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    # Step 1: Verification
    puts "STEP 1: VERIFYING SCORES"
    puts "-" * 40
    
    total_errors = 0
    total_users = User.count
    user_issues = []
    
    puts "Total users in system: #{total_users}"
    puts

    User.find_each do |user|
      puts "Verifying user: #{user.username} (ID: #{user.id})"
      
      # Calculate what the scores should be based on selections
      calculated_weekly_game_a = 0
      calculated_weekly_game_b = 0
      calculated_weekly_total = 0
      calculated_cumulative = 0
      
      user_errors = []
      
      # Get all selections for this user across all weeks
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
        
        # Handle tie games - both Game A and Game B get points
        if game.tie_game == true && selection.correct_pref_pick == true && selection.correct_spread_pick == true
          puts "  - Tie game detected for game #{game.id}"
        end
      end
      
      calculated_weekly_total = calculated_weekly_game_a + calculated_weekly_game_b
      
      # Check for discrepancies
      if user.weekly_points_game_a != calculated_weekly_game_a
        user_errors << "Game A points mismatch: stored=#{user.weekly_points_game_a}, calculated=#{calculated_weekly_game_a}"
      end
      
      if user.weekly_points_game_b != calculated_weekly_game_b
        user_errors << "Game B points mismatch: stored=#{user.weekly_points_game_b}, calculated=#{calculated_weekly_game_b}"
      end
      
      if user.weekly_points != calculated_weekly_total
        user_errors << "Weekly total mismatch: stored=#{user.weekly_points}, calculated=#{calculated_weekly_total}"
      end
      
      if user.cumulative_points != calculated_cumulative
        user_errors << "Cumulative points mismatch: stored=#{user.cumulative_points}, calculated=#{calculated_cumulative}"
      end
      
      # Report results for this user
      if user_errors.any?
        puts "  ❌ ERRORS FOUND:"
        user_errors.each { |error| puts "    - #{error}" }
        total_errors += user_errors.count
        user_issues << {
          user: user,
          errors: user_errors,
          calculated: {
            weekly_game_a: calculated_weekly_game_a,
            weekly_game_b: calculated_weekly_game_b,
            weekly_total: calculated_weekly_total,
            cumulative: calculated_cumulative
          }
        }
      else
        puts "  ✅ All scores correct"
      end
      
      puts "  Current: Game A=#{user.weekly_points_game_a}, Game B=#{user.weekly_points_game_b}, Weekly=#{user.weekly_points}, Cumulative=#{user.cumulative_points}"
      puts "  Calculated: Game A=#{calculated_weekly_game_a}, Game B=#{calculated_weekly_game_b}, Weekly=#{calculated_weekly_total}, Cumulative=#{calculated_cumulative}"
      puts
    end
    
    puts "VERIFICATION SUMMARY:"
    puts "Total users verified: #{total_users}"
    puts "Total errors found: #{total_errors}"
    puts
    
    # Step 2: If errors found, offer to fix them
    if total_errors > 0
      puts "STEP 2: SCORE CORRECTIONS NEEDED"
      puts "-" * 40
      puts "⚠️  ERRORS DETECTED!"
      puts "The following fixes would be applied:"
      puts
      
      user_issues.each do |issue|
        user = issue[:user]
        calculated = issue[:calculated]
        puts "User: #{user.username}"
        puts "  weekly_points_game_a: #{user.weekly_points_game_a} → #{calculated[:weekly_game_a]}"
        puts "  weekly_points_game_b: #{user.weekly_points_game_b} → #{calculated[:weekly_game_b]}"
        puts "  weekly_points: #{user.weekly_points} → #{calculated[:weekly_total]}"
        puts "  cumulative_points: #{user.cumulative_points} → #{calculated[:cumulative]}"
        puts
      end
      
      # Ask for confirmation
      print "Do you want to apply these fixes? (yes/no): "
      confirmation = STDIN.gets.chomp.downcase
      
      if confirmation == 'yes' || confirmation == 'y'
        puts
        puts "STEP 3: CREATING BACKUP"
        puts "-" * 40
        
        # Create backup
        backup_file = "user_scores_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
        backup_path = Rails.root.join(backup_file)
        
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
        puts "✅ Backup created: #{backup_file}"
        puts
        
        puts "STEP 4: APPLYING FIXES"
        puts "-" * 40
        
        total_fixes = 0
        user_issues.each do |issue|
          user = issue[:user]
          calculated = issue[:calculated]
          
          puts "Fixing user: #{user.username}"
          
          # Apply the fixes
          changes_made = []
          
          if user.weekly_points_game_a != calculated[:weekly_game_a]
            old_value = user.weekly_points_game_a
            user.weekly_points_game_a = calculated[:weekly_game_a]
            changes_made << "weekly_points_game_a: #{old_value} → #{calculated[:weekly_game_a]}"
          end
          
          if user.weekly_points_game_b != calculated[:weekly_game_b]
            old_value = user.weekly_points_game_b
            user.weekly_points_game_b = calculated[:weekly_game_b]
            changes_made << "weekly_points_game_b: #{old_value} → #{calculated[:weekly_game_b]}"
          end
          
          if user.weekly_points != calculated[:weekly_total]
            old_value = user.weekly_points
            user.weekly_points = calculated[:weekly_total]
            changes_made << "weekly_points: #{old_value} → #{calculated[:weekly_total]}"
          end
          
          if user.cumulative_points != calculated[:cumulative]
            old_value = user.cumulative_points
            user.cumulative_points = calculated[:cumulative]
            changes_made << "cumulative_points: #{old_value} → #{calculated[:cumulative]}"
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
        
        puts "FIX SUMMARY:"
        puts "Total fixes applied: #{total_fixes}"
        puts
        
        puts "STEP 5: FINAL VERIFICATION"
        puts "-" * 40
        
        # Re-verify everything
        final_errors = 0
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
            final_errors += 1
          end
        end
        
        if final_errors == 0
          puts "🎉 ALL SCORES ARE NOW CORRECT!"
          puts "✅ Safe to deploy to production."
        else
          puts "⚠️  Some errors remain. Please check the data."
        end
        
      else
        puts "❌ Fixes cancelled by user."
        puts "⚠️  DO NOT DEPLOY until errors are resolved."
      end
      
    else
      puts "🎉 ALL SCORES ARE CORRECT!"
      puts "✅ Safe to deploy to production."
    end
    
    puts
    puts "=" * 80
    puts "AUDIT COMPLETE"
    puts "=" * 80
  end

  desc "Quick score check - just verify without offering to fix"
  task :check => :environment do
    puts "=" * 80
    puts "QUICK SCORE CHECK"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_errors = 0
    total_users = User.count
    
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
        total_errors += 1
        puts "❌ #{user.username}: Score mismatch detected"
      else
        puts "✅ #{user.username}: Scores correct"
      end
    end
    
    puts
    puts "=" * 80
    puts "CHECK SUMMARY"
    puts "=" * 80
    puts "Total users: #{total_users}"
    puts "Users with errors: #{total_errors}"
    
    if total_errors == 0
      puts "🎉 ALL SCORES ARE CORRECT!"
    else
      puts "⚠️  ERRORS DETECTED!"
      puts "Run 'rake audit:scores' to fix them."
    end
    puts "=" * 80
  end
end

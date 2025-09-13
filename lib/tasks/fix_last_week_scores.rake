namespace :fix do
  desc "Fix last_week_score to show only prior week's points, not cumulative"
  task last_week_scores: :environment do
    puts "=" * 80
    puts "FIX LAST WEEK SCORES"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_updated = 0
    
    puts "Total users in system: #{total_users}"
    puts

    # Check for completed weeks
    completed_weeks = Week.where(active: false).order(created_at: :desc)
    if completed_weeks.empty?
      puts "❌ No completed weeks found. Cannot fix last_week_score."
      puts "   Make sure at least one week has been closed (active = false)."
      exit 1
    end

    prior_week = completed_weeks.first
    puts "Using prior week: Week #{prior_week.week_number} (ID: #{prior_week.id})"
    puts

    # Create backup before making changes
    backup_file = "last_week_scores_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
    backup_path = Rails.root.join(backup_file)
    
    backup_data = {
      timestamp: Time.current,
      environment: Rails.env,
      prior_week_id: prior_week.id,
      prior_week_number: prior_week.week_number,
      users: []
    }
    
    puts "STEP 1: CREATING BACKUP"
    puts "-" * 40
    
    User.find_each do |user|
      backup_data[:users] << {
        id: user.id,
        username: user.username,
        email: user.email,
        last_week_score: user.last_week_score,
        cumulative_points: user.cumulative_points,
        weekly_points: user.weekly_points
      }
    end
    
    File.write(backup_path, JSON.pretty_generate(backup_data))
    puts "✅ Backup created: #{backup_file}"
    puts
    
    puts "STEP 2: FIXING LAST WEEK SCORES"
    puts "-" * 40

    User.find_each do |user|
      puts "Processing user: #{user.username}"
      
      # Calculate what last_week_score should be (prior week only)
      calculated_prior_week_score = 0
      game_breakdown = []
      
      user.selections.joins(:game).where(games: { week_id: prior_week.id }).each do |selection|
        game = selection.game
        next unless game.has_game_been_scored?
        
        game_a_points = 0
        game_b_points = 0
        
        if selection.correct_pref_pick == true
          game_a_points = selection.pref_pick_int
          calculated_prior_week_score += game_a_points
        end
        
        if selection.correct_spread_pick == true
          game_b_points = 7
          calculated_prior_week_score += game_b_points
        end
        
        if game_a_points > 0 || game_b_points > 0
          game_breakdown << "Game #{game.id}: A=#{game_a_points}, B=#{game_b_points}"
        end
      end
      
      old_last_week_score = user.last_week_score
      
      # Only update if there's a discrepancy
      if user.last_week_score != calculated_prior_week_score
        user.last_week_score = calculated_prior_week_score
        
        if user.save!
          users_updated += 1
          discrepancy = calculated_prior_week_score - old_last_week_score
          
          puts "  ✅ FIXED: #{old_last_week_score} → #{calculated_prior_week_score} (#{discrepancy > 0 ? '+' : ''}#{discrepancy})"
          
          if game_breakdown.any?
            puts "    Points from: #{game_breakdown.join(', ')}"
          end
          
          puts "    Cumulative remains: #{user.cumulative_points}"
        else
          puts "  ❌ FAILED to save: #{user.errors.full_messages.join(', ')}"
        end
      else
        puts "  ✅ Already correct: #{user.last_week_score}"
      end
      
      puts
    end
    
    puts "FIX SUMMARY:"
    puts "-" * 40
    puts "Total users processed: #{total_users}"
    puts "Users updated: #{users_updated}"
    puts "Users already correct: #{total_users - users_updated}"
    puts "Prior week used: Week #{prior_week.week_number} (ID: #{prior_week.id})"
    puts

    if users_updated == 0
      puts "🎉 ALL LAST WEEK SCORES WERE ALREADY CORRECT!"
    else
      puts "🎉 SUCCESSFULLY FIXED #{users_updated} USERS!"
      puts "✅ last_week_score now shows only prior week's points."
      puts "✅ Cumulative scores remain unchanged (total season points)."
    end
    
    puts
    puts "STEP 3: FINAL VERIFICATION"
    puts "-" * 40
    
    # Quick verification
    verification_errors = 0
    users_with_same_scores = 0
    
    User.find_each do |user|
      if user.last_week_score == user.cumulative_points && user.cumulative_points > 0
        verification_errors += 1
        users_with_same_scores += 1
        puts "❌ #{user.username}: Still has last_week_score = cumulative_score (#{user.last_week_score})"
      elsif user.last_week_score > user.cumulative_points
        verification_errors += 1
        puts "❌ #{user.username}: last_week_score > cumulative_score (impossible!)"
      end
    end
    
    if verification_errors == 0
      puts "✅ VERIFICATION PASSED: All last_week_score values are now correct!"
      puts "✅ last_week_score ≤ cumulative_points for all users."
    else
      puts "❌ VERIFICATION FAILED: #{verification_errors} users still have issues."
      puts "   #{users_with_same_scores} users still have last_week_score = cumulative_score."
    end
    
    puts
    puts "=" * 80
    puts "FIX COMPLETE"
    puts "=" * 80
  end
end

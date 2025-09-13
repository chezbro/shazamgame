namespace :fix do
  desc "Fix weekly scores on Heroku - calculate actual prior week scores from Score records"
  task weekly_scores: :environment do
    puts "=" * 80
    puts "FIX WEEKLY SCORES ON HEROKU"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_updated = 0
    
    puts "Total users in system: #{total_users}"
    puts
    
    # Find the most recent completed week (not active)
    completed_weeks = Week.where(active: false).order(created_at: :desc)
    if completed_weeks.empty?
      puts "❌ No completed weeks found. Cannot calculate prior week scores."
      puts "   Make sure at least one week has been closed (active = false)."
      exit 1
    end
    
    prior_week = completed_weeks.first
    puts "Using prior week: Week #{prior_week.week_number} (ID: #{prior_week.id})"
    puts
    
    # Create backup before making changes
    backup_file = "weekly_scores_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
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
        current_weekly_points: user.weekly_points,
        current_last_week_score: user.last_week_score,
        cumulative_points: user.cumulative_points
      }
    end
    
    File.write(backup_path, JSON.pretty_generate(backup_data))
    puts "✅ Backup created: #{backup_file}"
    puts
    
    puts "STEP 2: CALCULATING PRIOR WEEK SCORES"
    puts "-" * 40
    
    User.find_each do |user|
      old_last_week_score = user.last_week_score
      old_weekly_points = user.weekly_points
      
      # Try to get score from Score table first
      score_record = Score.find_by(week_id: prior_week.id, user_id: user.id)
      
      if score_record
        # Use the stored score record
        calculated_prior_week_score = score_record.points_for_week
        source = "Score record"
      else
        # Calculate from selections if no score record exists
        calculated_prior_week_score = 0
        source = "Calculated from selections"
        
        user.selections.joins(:game).where(games: { week_id: prior_week.id }).each do |selection|
          game = selection.game
          next unless game.has_game_been_scored?
          
          # Game A points (preference picks)
          if selection.correct_pref_pick == true
            calculated_prior_week_score += selection.pref_pick_int
          end
          
          # Game B points (spread picks)
          if selection.correct_spread_pick == true
            calculated_prior_week_score += 7
          end
        end
      end
      
      # Update the user's last_week_score
      user.last_week_score = calculated_prior_week_score
      
      if user.save!
        users_updated += 1
        puts "✅ Updated #{user.username}:"
        puts "   last_week_score: #{old_last_week_score} → #{user.last_week_score} (#{source})"
        puts "   weekly_points: #{old_weekly_points} (unchanged)"
      else
        puts "❌ Failed to update #{user.username}: #{user.errors.full_messages.join(', ')}"
      end
    end
    
    puts
    puts "FIX SUMMARY:"
    puts "Total users processed: #{total_users}"
    puts "Users successfully updated: #{users_updated}"
    puts "Users failed to update: #{total_users - users_updated}"
    puts "Prior week used: Week #{prior_week.week_number} (ID: #{prior_week.id})"
    puts
    
    if users_updated == total_users
      puts "🎉 ALL WEEKLY SCORES FIXED SUCCESSFULLY!"
      puts "✅ The 'Top Scores for the Week' leaderboard will now show actual prior week scores."
      puts "✅ Safe to deploy this fix to production."
    else
      puts "⚠️  Some users failed to update. Please check the errors above."
    end
    
    puts
    puts "=" * 80
    puts "FIX COMPLETE"
    puts "=" * 80
  end

  desc "Quick check of weekly scores status"
  task :check_weekly_scores => :environment do
    puts "=" * 80
    puts "WEEKLY SCORES STATUS CHECK"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_with_zero_last_week = 0
    users_with_cumulative_scores = 0
    users_with_proper_scores = 0
    
    puts "Total users in system: #{total_users}"
    puts
    
    # Check for completed weeks
    completed_weeks = Week.where(active: false).order(created_at: :desc)
    if completed_weeks.empty?
      puts "⚠️  No completed weeks found. Cannot determine proper prior week scores."
    else
      prior_week = completed_weeks.first
      puts "Most recent completed week: Week #{prior_week.week_number} (ID: #{prior_week.id})"
    end
    puts
    
    User.find_each do |user|
      if user.last_week_score == 0
        users_with_zero_last_week += 1
        puts "❌ #{user.username}: last_week_score is 0 (needs fixing)"
      elsif user.last_week_score == user.weekly_points && user.weekly_points > 0
        users_with_cumulative_scores += 1
        puts "⚠️  #{user.username}: last_week_score matches cumulative weekly_points (#{user.last_week_score}) - likely wrong!"
      else
        users_with_proper_scores += 1
        puts "✅ #{user.username}: last_week=#{user.last_week_score}, weekly=#{user.weekly_points}"
      end
    end
    
    puts
    puts "=" * 80
    puts "STATUS SUMMARY"
    puts "=" * 80
    puts "Total users: #{total_users}"
    puts "Users with zero last_week_score: #{users_with_zero_last_week}"
    puts "Users with cumulative scores in last_week_score: #{users_with_cumulative_scores}"
    puts "Users with proper scores: #{users_with_proper_scores}"
    
    if users_with_zero_last_week > 0 || users_with_cumulative_scores > 0
      puts "⚠️  #{users_with_zero_last_week + users_with_cumulative_scores} users need their weekly scores fixed."
      puts "   Run 'rake fix:weekly_scores' to calculate proper prior week scores."
    else
      puts "🎉 All users have proper last_week_score values!"
    end
    
    puts "=" * 80
  end
end

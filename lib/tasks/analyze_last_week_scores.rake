namespace :analyze do
  desc "Analyze why last_week_score equals cumulative_score instead of prior week only"
  task last_week_scores: :environment do
    puts "=" * 80
    puts "LAST WEEK SCORES ANALYSIS"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_with_issue = 0
    users_with_correct_last_week = 0
    users_with_zero_last_week = 0
    
    puts "Total users in system: #{total_users}"
    puts

    # Check for completed weeks
    completed_weeks = Week.where(active: false).order(created_at: :desc)
    if completed_weeks.empty?
      puts "❌ No completed weeks found. Cannot analyze last_week_score properly."
      puts "   This explains why last_week_score might equal cumulative_score."
      exit 1
    end

    prior_week = completed_weeks.first
    puts "Most recent completed week: Week #{prior_week.week_number} (ID: #{prior_week.id})"
    puts

    puts "ANALYSIS BY USER:"
    puts "-" * 40

    User.find_each do |user|
      puts "User: #{user.username}"
      puts "  cumulative_points: #{user.cumulative_points}"
      puts "  last_week_score: #{user.last_week_score}"
      puts "  weekly_points: #{user.weekly_points}"
      
      # Calculate what last_week_score should be (prior week only)
      calculated_prior_week_score = 0
      
      user.selections.joins(:game).where(games: { week_id: prior_week.id }).each do |selection|
        game = selection.game
        next unless game.has_game_been_scored?
        
        if selection.correct_pref_pick == true
          calculated_prior_week_score += selection.pref_pick_int
        end
        
        if selection.correct_spread_pick == true
          calculated_prior_week_score += 7
        end
      end
      
      puts "  calculated_prior_week_score: #{calculated_prior_week_score}"
      
      # Analyze the issue
      if user.last_week_score == 0
        users_with_zero_last_week += 1
        puts "  ❌ ISSUE: last_week_score is 0 (never set properly)"
      elsif user.last_week_score == user.cumulative_points
        users_with_issue += 1
        puts "  ❌ ISSUE: last_week_score equals cumulative_score (WRONG!)"
        puts "     Should be: #{calculated_prior_week_score}"
      elsif user.last_week_score == calculated_prior_week_score
        users_with_correct_last_week += 1
        puts "  ✅ CORRECT: last_week_score matches calculated prior week score"
      else
        puts "  ⚠️  UNCLEAR: last_week_score doesn't match any expected value"
      end
      
      puts
    end

    puts "SUMMARY:"
    puts "-" * 40
    puts "Total users: #{total_users}"
    puts "Users with correct last_week_score: #{users_with_correct_last_week}"
    puts "Users with last_week_score = cumulative (WRONG): #{users_with_issue}"
    puts "Users with last_week_score = 0: #{users_with_zero_last_week}"
    puts

    if users_with_issue > 0
      puts "🔍 ROOT CAUSE ANALYSIS:"
      puts "-" * 40
      puts "The issue is that last_week_score is set to cumulative_points instead of just the prior week's points."
      puts
      puts "This likely happened because:"
      puts "1. The User.set_weekly_points_to_zero method was never called when weeks were closed"
      puts "2. OR the method was called but weekly_points contained cumulative data instead of just that week's data"
      puts "3. OR the last_week_score was manually set incorrectly at some point"
      puts
      puts "🔧 SOLUTION:"
      puts "Run 'rake fix:last_week_scores' to calculate and set correct prior week scores."
    elsif users_with_zero_last_week > 0
      puts "🔍 ROOT CAUSE ANALYSIS:"
      puts "-" * 40
      puts "The issue is that last_week_score was never set when weeks were closed."
      puts
      puts "This means:"
      puts "1. The User.set_weekly_points_to_zero method was never called"
      puts "2. OR weeks were never properly closed (active flag never set to false)"
      puts
      puts "🔧 SOLUTION:"
      puts "Run 'rake fix:last_week_scores' to calculate and set correct prior week scores."
    else
      puts "🎉 All last_week_score values are correct!"
    end

    puts
    puts "=" * 80
    puts "ANALYSIS COMPLETE"
    puts "=" * 80
  end
end

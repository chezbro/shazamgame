namespace :verify do
  desc "Comprehensive verification of ALL point totals - weekly, cumulative, Game A, Game B"
  task all_points: :environment do
    puts "=" * 80
    puts "COMPREHENSIVE POINT VERIFICATION"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_with_errors = 0
    total_discrepancies = 0
    
    puts "Total users in system: #{total_users}"
    puts

    # Check if there are any scored games
    scored_games = Game.where(has_game_been_scored: true)
    if scored_games.empty?
      puts "❌ No scored games found. Cannot verify point totals."
      puts "   Please score at least one game first."
      exit 1
    end

    puts "Found #{scored_games.count} scored games across all weeks"
    puts "Weeks with scored games: #{scored_games.joins(:week).pluck(:week_number).uniq.sort.join(', ')}"
    puts

    puts "STEP 1: VERIFYING ALL POINT TOTALS"
    puts "-" * 40

    User.find_each do |user|
      puts "Verifying user: #{user.username} (ID: #{user.id})"
      
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
          game_breakdown << "    Week #{game.week.week_number} Game #{game.id}: A=#{game_a_points}, B=#{game_b_points}, Total=#{total_game_points}"
        end
      end
      
      # Check for discrepancies in ALL fields
      discrepancies = []
      
      if user.weekly_points_game_a != calculated_weekly_game_a
        discrepancies << "Game A points mismatch: stored=#{user.weekly_points_game_a}, calculated=#{calculated_weekly_game_a}"
      end
      
      if user.weekly_points_game_b != calculated_weekly_game_b
        discrepancies << "Game B points mismatch: stored=#{user.weekly_points_game_b}, calculated=#{calculated_weekly_game_b}"
      end
      
      if user.weekly_points != calculated_weekly_total
        discrepancies << "Weekly total mismatch: stored=#{user.weekly_points}, calculated=#{calculated_weekly_total}"
      end
      
      if user.cumulative_points != calculated_cumulative
        discrepancies << "Cumulative points mismatch: stored=#{user.cumulative_points}, calculated=#{calculated_cumulative}"
      end
      
      # Check if weekly_points equals the sum of game_a + game_b
      if user.weekly_points != (user.weekly_points_game_a + user.weekly_points_game_b)
        discrepancies << "Weekly points inconsistency: weekly_points=#{user.weekly_points}, but game_a + game_b = #{user.weekly_points_game_a + user.weekly_points_game_b}"
      end
      
      if discrepancies.any?
        users_with_errors += 1
        total_discrepancies += discrepancies.count
        
        puts "  ❌ ERRORS FOUND:"
        discrepancies.each { |error| puts "    - #{error}" }
        
        puts "  Current stored values:"
        puts "    weekly_points_game_a: #{user.weekly_points_game_a}"
        puts "    weekly_points_game_b: #{user.weekly_points_game_b}"
        puts "    weekly_points: #{user.weekly_points}"
        puts "    cumulative_points: #{user.cumulative_points}"
        puts "    last_week_score: #{user.last_week_score}"
        
        puts "  Calculated correct values:"
        puts "    weekly_points_game_a: #{calculated_weekly_game_a}"
        puts "    weekly_points_game_b: #{calculated_weekly_game_b}"
        puts "    weekly_points: #{calculated_weekly_total}"
        puts "    cumulative_points: #{calculated_cumulative}"
        
        if game_breakdown.any?
          puts "  Points breakdown:"
          game_breakdown.each { |detail| puts detail }
        end
      else
        puts "  ✅ All point totals correct"
        puts "    weekly_points_game_a: #{user.weekly_points_game_a}"
        puts "    weekly_points_game_b: #{user.weekly_points_game_b}"
        puts "    weekly_points: #{user.weekly_points}"
        puts "    cumulative_points: #{user.cumulative_points}"
      end
      
      puts
    end
    
    puts "VERIFICATION SUMMARY:"
    puts "-" * 40
    puts "Total users verified: #{total_users}"
    puts "Users with point errors: #{users_with_errors}"
    puts "Users with correct points: #{total_users - users_with_errors}"
    puts "Total discrepancies found: #{total_discrepancies}"
    puts

    if users_with_errors == 0
      puts "🎉 ALL POINT TOTALS ARE CORRECT!"
      puts "✅ All users have accurate scores across all fields."
    else
      puts "⚠️  #{users_with_errors} users have incorrect point totals!"
      puts "   Total discrepancies: #{total_discrepancies}"
      puts
      puts "🔧 TO FIX ALL POINT TOTALS:"
      puts "   Run 'rake fix:all_points' to correct them."
    end
    
    puts
    puts "=" * 80
    puts "VERIFICATION COMPLETE"
    puts "=" * 80
  end

  desc "Quick check of all point totals"
  task :check_all_points => :environment do
    puts "=" * 80
    puts "QUICK POINT CHECK"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_with_errors = 0
    
    puts "Total users in system: #{total_users}"
    puts

    User.find_each do |user|
      # Quick calculation
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
      
      # Check for any discrepancies
      has_errors = false
      errors = []
      
      if user.weekly_points_game_a != calculated_weekly_game_a
        has_errors = true
        errors << "GameA:#{user.weekly_points_game_a}→#{calculated_weekly_game_a}"
      end
      
      if user.weekly_points_game_b != calculated_weekly_game_b
        has_errors = true
        errors << "GameB:#{user.weekly_points_game_b}→#{calculated_weekly_game_b}"
      end
      
      if user.weekly_points != calculated_weekly_total
        has_errors = true
        errors << "Weekly:#{user.weekly_points}→#{calculated_weekly_total}"
      end
      
      if user.cumulative_points != calculated_cumulative
        has_errors = true
        errors << "Cumulative:#{user.cumulative_points}→#{calculated_cumulative}"
      end
      
      if user.weekly_points != (user.weekly_points_game_a + user.weekly_points_game_b)
        has_errors = true
        errors << "Inconsistent weekly total"
      end
      
      if has_errors
        users_with_errors += 1
        puts "❌ #{user.username}: #{errors.join(', ')}"
      else
        puts "✅ #{user.username}: All correct (Weekly:#{user.weekly_points}, Cumulative:#{user.cumulative_points})"
      end
    end
    
    puts
    puts "=" * 80
    puts "QUICK CHECK SUMMARY"
    puts "=" * 80
    puts "Total users: #{total_users}"
    puts "Users with errors: #{users_with_errors}"
    
    if users_with_errors == 0
      puts "🎉 ALL POINT TOTALS ARE CORRECT!"
    else
      puts "⚠️  #{users_with_errors} users need point totals fixed."
      puts "   Run 'rake verify:all_points' for detailed analysis."
    end
    
    puts "=" * 80
  end
end

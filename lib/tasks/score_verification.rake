namespace :verification do
  desc "Verify all weekly and cumulative scores are correct"
  task verify_scores: :environment do
    puts "=" * 80
    puts "SCORE VERIFICATION REPORT"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_errors = 0
    total_users = User.count
    puts "Total users in system: #{total_users}"
    puts

    # Verify each user's scores
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
          # Points already added above, but let's verify the logic
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
      else
        puts "  ✅ All scores correct"
      end
      
      puts "  Current scores: Game A=#{user.weekly_points_game_a}, Game B=#{user.weekly_points_game_b}, Weekly=#{user.weekly_points}, Cumulative=#{user.cumulative_points}"
      puts "  Calculated scores: Game A=#{calculated_weekly_game_a}, Game B=#{calculated_weekly_game_b}, Weekly=#{calculated_weekly_total}, Cumulative=#{calculated_cumulative}"
      puts
    end
    
    puts "=" * 80
    puts "VERIFICATION SUMMARY"
    puts "=" * 80
    puts "Total users verified: #{total_users}"
    puts "Total errors found: #{total_errors}"
    
    if total_errors == 0
      puts "🎉 ALL SCORES ARE CORRECT!"
      puts "Safe to deploy to production."
    else
      puts "⚠️  ERRORS DETECTED!"
      puts "DO NOT DEPLOY until errors are resolved."
    end
    puts "=" * 80
  end

  desc "Show detailed breakdown of a specific user's scores"
  task :user_breakdown, [:username] => :environment do |t, args|
    unless args[:username]
      puts "Usage: rake verification:user_breakdown[username]"
      exit 1
    end
    
    user = User.find_by(username: args[:username])
    unless user
      puts "User '#{args[:username]}' not found"
      exit 1
    end
    
    puts "=" * 80
    puts "DETAILED BREAKDOWN FOR USER: #{user.username}"
    puts "=" * 80
    
    puts "Current stored scores:"
    puts "  Game A points: #{user.weekly_points_game_a}"
    puts "  Game B points: #{user.weekly_points_game_b}"
    puts "  Weekly total: #{user.weekly_points}"
    puts "  Cumulative: #{user.cumulative_points}"
    puts
    
    puts "Selection-by-selection breakdown:"
    puts "Week | Game | Team A | Team B | Pref Pick | Spread Pick | Pref Result | Spread Result | Points"
    puts "-" * 120
    
    calculated_game_a = 0
    calculated_game_b = 0
    
    user.selections.includes(:game, :week).order('weeks.week_number, games.id').each do |selection|
      game = selection.game
      week = game.week
      
      pref_result = selection.correct_pref_pick ? "✅" : "❌"
      spread_result = selection.correct_spread_pick ? "✅" : "❌"
      
      pref_points = selection.correct_pref_pick ? selection.pref_pick_int : 0
      spread_points = selection.correct_spread_pick ? 7 : 0
      
      calculated_game_a += pref_points
      calculated_game_b += spread_points
      
      puts "#{week.week_number.to_s.rjust(4)} | #{game.id.to_s.rjust(4)} | #{game.home_team&.region || 'N/A'} | #{game.away_team&.region || 'N/A'} | #{selection.pref_pick_int.to_s.rjust(9)} | #{selection.spread_pick_team == game.home_team_id ? 'Home' : 'Away'.ljust(11)} | #{pref_result.ljust(10)} | #{spread_result.ljust(11)} | #{pref_points + spread_points}"
    end
    
    puts "-" * 120
    puts "Calculated totals:"
    puts "  Game A points: #{calculated_game_a}"
    puts "  Game B points: #{calculated_game_b}"
    puts "  Weekly total: #{calculated_game_a + calculated_game_b}"
    puts "  Cumulative: #{user.cumulative_points}"
    puts "=" * 80
  end

  desc "Verify leaderboard calculations match individual user scores"
  task verify_leaderboards: :environment do
    puts "=" * 80
    puts "LEADERBOARD VERIFICATION"
    puts "=" * 80
    
    # Test weekly leaderboard
    puts "Testing weekly leaderboard..."
    weekly_leaderboard = User.weekly_points
    puts "Weekly leaderboard (top 5):"
    weekly_leaderboard.each_with_index do |(points, username), index|
      user = User.find_by(username: username)
      if user.weekly_points != points
        puts "  ❌ User #{username}: leaderboard shows #{points}, but user.weekly_points = #{user.weekly_points}"
      else
        puts "  ✅ User #{username}: #{points} points"
      end
    end
    
    puts
    
    # Test cumulative leaderboard
    puts "Testing cumulative leaderboard..."
    cumulative_leaderboard = User.cumulative_points
    puts "Cumulative leaderboard (top 5):"
    cumulative_leaderboard.each_with_index do |(points, username), index|
      user = User.find_by(username: username)
      if user.cumulative_points != points
        puts "  ❌ User #{username}: leaderboard shows #{points}, but user.cumulative_points = #{user.cumulative_points}"
      else
        puts "  ✅ User #{username}: #{points} points"
      end
    end
    
    puts "=" * 80
  end
end

namespace :verify do
  desc "Verify all cumulative scores are correct - should match total season points"
  task cumulative_scores: :environment do
    puts "=" * 80
    puts "CUMULATIVE SCORES VERIFICATION"
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
      puts "❌ No scored games found. Cannot verify cumulative scores."
      puts "   Please score at least one game first."
      exit 1
    end

    puts "Found #{scored_games.count} scored games across all weeks"
    puts "Weeks with scored games: #{scored_games.joins(:week).pluck(:week_number).uniq.sort.join(', ')}"
    puts

    puts "STEP 1: VERIFYING CUMULATIVE SCORES"
    puts "-" * 40

    User.find_each do |user|
      puts "Verifying user: #{user.username} (ID: #{user.id})"
      
      # Calculate what cumulative points should be based on all scored games
      calculated_cumulative = 0
      game_details = []
      
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
          game_details << "    Game #{game.id} (Week #{game.week.week_number}): +#{total_game_points} (A:#{game_a_points} + B:#{game_b_points})"
        end
      end
      
      # Check for discrepancy
      if user.cumulative_points != calculated_cumulative
        users_with_errors += 1
        discrepancy = (calculated_cumulative - user.cumulative_points).abs
        total_discrepancies += discrepancy
        
        puts "  ❌ CUMULATIVE SCORE MISMATCH:"
        puts "    Stored cumulative_points: #{user.cumulative_points}"
        puts "    Calculated cumulative: #{calculated_cumulative}"
        puts "    Discrepancy: #{discrepancy} points"
        
        if game_details.any?
          puts "    Points breakdown:"
          game_details.each { |detail| puts detail }
        end
        
        puts "    Current weekly scores:"
        puts "      weekly_points: #{user.weekly_points}"
        puts "      weekly_points_game_a: #{user.weekly_points_game_a}"
        puts "      weekly_points_game_b: #{user.weekly_points_game_b}"
        puts "      last_week_score: #{user.last_week_score}"
      else
        puts "  ✅ Cumulative score correct: #{user.cumulative_points}"
        if game_details.any?
          puts "    Points breakdown:"
          game_details.each { |detail| puts detail }
        end
      end
      
      puts
    end
    
    puts "VERIFICATION SUMMARY:"
    puts "-" * 40
    puts "Total users verified: #{total_users}"
    puts "Users with cumulative score errors: #{users_with_errors}"
    puts "Users with correct cumulative scores: #{total_users - users_with_errors}"
    puts "Total point discrepancies: #{total_discrepancies}"
    puts

    if users_with_errors == 0
      puts "🎉 ALL CUMULATIVE SCORES ARE CORRECT!"
      puts "✅ All users have accurate total season points."
    else
      puts "⚠️  #{users_with_errors} users have incorrect cumulative scores!"
      puts "   Total discrepancies: #{total_discrepancies} points"
      puts
      puts "🔧 TO FIX CUMULATIVE SCORES:"
      puts "   Run 'rake fix:cumulative_scores' to correct them."
    end
    
    puts
    puts "=" * 80
    puts "VERIFICATION COMPLETE"
    puts "=" * 80
  end

  desc "Quick check of cumulative scores status"
  task :check_cumulative => :environment do
    puts "=" * 80
    puts "CUMULATIVE SCORES QUICK CHECK"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    total_users = User.count
    users_with_errors = 0
    total_discrepancies = 0
    
    puts "Total users in system: #{total_users}"
    puts

    User.find_each do |user|
      # Quick calculation - just sum up points from selections
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
        users_with_errors += 1
        discrepancy = (calculated_cumulative - user.cumulative_points).abs
        total_discrepancies += discrepancy
        puts "❌ #{user.username}: stored=#{user.cumulative_points}, calculated=#{calculated_cumulative} (diff: #{discrepancy})"
      else
        puts "✅ #{user.username}: #{user.cumulative_points} points"
      end
    end
    
    puts
    puts "=" * 80
    puts "QUICK CHECK SUMMARY"
    puts "=" * 80
    puts "Total users: #{total_users}"
    puts "Users with errors: #{users_with_errors}"
    puts "Total discrepancies: #{total_discrepancies} points"
    
    if users_with_errors == 0
      puts "🎉 ALL CUMULATIVE SCORES ARE CORRECT!"
    else
      puts "⚠️  #{users_with_errors} users need cumulative scores fixed."
      puts "   Run 'rake verify:cumulative_scores' for detailed analysis."
    end
    
    puts "=" * 80
  end
end

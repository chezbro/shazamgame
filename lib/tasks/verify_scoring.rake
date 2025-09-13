namespace :verify do
  desc "Verify that scoring logic works correctly for Game A, Game B, weekly, and cumulative totals"
  task scoring: :environment do
    puts "=" * 80
    puts "SCORING LOGIC VERIFICATION"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    puts "This task will analyze the current scoring logic and identify any issues."
    puts

    # Check if there are any scored games to analyze
    scored_games = Game.where(has_game_been_scored: true)
    if scored_games.empty?
      puts "❌ No scored games found. Cannot verify scoring logic."
      puts "   Please score at least one game first."
      exit 1
    end

    puts "Found #{scored_games.count} scored games to analyze"
    puts

    # Analyze the scoring logic issues
    puts "STEP 1: ANALYZING SCORING LOGIC ISSUES"
    puts "-" * 40

    puts "🔍 IDENTIFIED ISSUES IN tally_points METHOD:"
    puts
    puts "❌ ISSUE 1: Double counting in tie games"
    puts "   Lines 192-203: When tie_game = true, points are added twice:"
    puts "   - First in Game B logic (lines 153-174): +7 points"
    puts "   - Then again in tie game logic (lines 192-203): +7 + pref_pick_int points"
    puts "   This results in DOUBLE SCORING for tie games!"
    puts

    puts "❌ ISSUE 2: Missing weekly_points update in Game A logic"
    puts "   Lines 177-188: Game A logic only updates:"
    puts "   - weekly_points_game_a += selection.pref_pick_int"
    puts "   - cumulative_points += selection.pref_pick_int"
    puts "   But MISSING: user.weekly_points += selection.pref_pick_int"
    puts "   This means weekly_points total is incomplete!"
    puts

    puts "❌ ISSUE 3: Inconsistent weekly_points calculation"
    puts "   The weekly_points field should = weekly_points_game_a + weekly_points_game_b"
    puts "   But the current logic doesn't maintain this consistency."
    puts

    puts "STEP 2: TESTING CURRENT SCORING WITH SAMPLE DATA"
    puts "-" * 40

    # Find a user with selections to test
    user_with_selections = User.joins(:selections).where(selections: { game_id: scored_games.pluck(:id) }).first
    
    if user_with_selections.nil?
      puts "❌ No users found with selections in scored games."
      puts "   Cannot test scoring calculations."
      exit 1
    end

    puts "Testing with user: #{user_with_selections.username}"
    puts "Current scores:"
    puts "  weekly_points: #{user_with_selections.weekly_points}"
    puts "  weekly_points_game_a: #{user_with_selections.weekly_points_game_a}"
    puts "  weekly_points_game_b: #{user_with_selections.weekly_points_game_b}"
    puts "  cumulative_points: #{user_with_selections.cumulative_points}"
    puts

    # Calculate what the scores should be
    calculated_weekly_game_a = 0
    calculated_weekly_game_b = 0
    calculated_weekly_total = 0
    calculated_cumulative = 0

    puts "Recalculating scores from selections:"
    
    user_with_selections.selections.includes(:game).each do |selection|
      game = selection.game
      next unless game.has_game_been_scored?
      
      puts "  Game #{game.id} (Week #{game.week.week_number}):"
      puts "    Pref pick: #{selection.pref_pick_team} (correct: #{selection.correct_pref_pick}, points: #{selection.pref_pick_int})"
      puts "    Spread pick: #{selection.spread_pick_team} (correct: #{selection.correct_spread_pick})"
      puts "    Tie game: #{game.tie_game}"
      
      # Game A calculation
      if selection.correct_pref_pick == true
        calculated_weekly_game_a += selection.pref_pick_int
        calculated_cumulative += selection.pref_pick_int
        puts "    ✅ Game A: +#{selection.pref_pick_int} points"
      else
        puts "    ❌ Game A: 0 points"
      end
      
      # Game B calculation
      if selection.correct_spread_pick == true
        calculated_weekly_game_b += 7
        calculated_cumulative += 7
        puts "    ✅ Game B: +7 points"
      else
        puts "    ❌ Game B: 0 points"
      end
      
      puts
    end

    calculated_weekly_total = calculated_weekly_game_a + calculated_weekly_game_b

    puts "CALCULATION RESULTS:"
    puts "  Calculated weekly_points_game_a: #{calculated_weekly_game_a}"
    puts "  Stored weekly_points_game_a: #{user_with_selections.weekly_points_game_a}"
    puts "  Calculated weekly_points_game_b: #{calculated_weekly_game_b}"
    puts "  Stored weekly_points_game_b: #{user_with_selections.weekly_points_game_b}"
    puts "  Calculated weekly_total: #{calculated_weekly_total}"
    puts "  Stored weekly_points: #{user_with_selections.weekly_points}"
    puts "  Calculated cumulative: #{calculated_cumulative}"
    puts "  Stored cumulative_points: #{user_with_selections.cumulative_points}"
    puts

    # Check for discrepancies
    discrepancies = []
    if calculated_weekly_game_a != user_with_selections.weekly_points_game_a
      discrepancies << "Game A points mismatch"
    end
    if calculated_weekly_game_b != user_with_selections.weekly_points_game_b
      discrepancies << "Game B points mismatch"
    end
    if calculated_weekly_total != user_with_selections.weekly_points
      discrepancies << "Weekly total mismatch"
    end
    if calculated_cumulative != user_with_selections.cumulative_points
      discrepancies << "Cumulative points mismatch"
    end

    if discrepancies.empty?
      puts "✅ All calculations match stored values!"
    else
      puts "❌ DISCREPANCIES FOUND:"
      discrepancies.each { |d| puts "  - #{d}" }
    end

    puts
    puts "STEP 3: RECOMMENDATIONS"
    puts "-" * 40
    puts "🔧 TO FIX THE SCORING ISSUES:"
    puts
    puts "1. Fix double counting in tie games:"
    puts "   - Remove duplicate point additions in tie game logic"
    puts "   - OR skip the regular Game A/Game B logic when tie_game = true"
    puts
    puts "2. Fix missing weekly_points update in Game A:"
    puts "   - Add: user.weekly_points += selection.pref_pick_int"
    puts "   - Ensure weekly_points = weekly_points_game_a + weekly_points_game_b"
    puts
    puts "3. Add consistency checks:"
    puts "   - Verify weekly_points always equals the sum of Game A + Game B"
    puts "   - Consider making weekly_points a calculated field instead of stored"
    puts
    puts "4. Test thoroughly with different scenarios:"
    puts "   - Regular wins (Game A correct, Game B correct)"
    puts "   - Partial wins (Game A correct, Game B incorrect)"
    puts "   - Tie games"
    puts "   - Push games (spread ties)"
    puts

    puts "=" * 80
    puts "VERIFICATION COMPLETE"
    puts "=" * 80
  end
end

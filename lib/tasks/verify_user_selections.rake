namespace :verify do
  desc "Verify a specific user's selection picks and point totals"
  task :user_selections, [:username] => :environment do |t, args|
    if args[:username].blank?
      puts "❌ Please provide a username. Usage: rake verify:user_selections[username]"
      exit 1
    end

    username = args[:username]
    user = User.find_by(username: username)
    
    if user.nil?
      puts "❌ User '#{username}' not found."
      puts "Available users:"
      User.all.each { |u| puts "  - #{u.username}" }
      exit 1
    end

    puts "=" * 80
    puts "USER SELECTION VERIFICATION: #{user.username}"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "User ID: #{user.id}"
    puts "=" * 80

    puts "STEP 1: USER PROFILE"
    puts "-" * 40
    puts "Username: #{user.username}"
    puts "Email: #{user.email}"
    puts "Active: #{user.active}"
    puts

    puts "STEP 2: CURRENT STORED SCORES"
    puts "-" * 40
    puts "weekly_points: #{user.weekly_points}"
    puts "weekly_points_game_a: #{user.weekly_points_game_a}"
    puts "weekly_points_game_b: #{user.weekly_points_game_b}"
    puts "cumulative_points: #{user.cumulative_points}"
    puts "last_week_score: #{user.last_week_score}"
    puts

    puts "STEP 3: SELECTIONS ANALYSIS"
    puts "-" * 40

    total_selections = user.selections.count
    selections_with_scores = user.selections.joins(:game).where(games: { has_game_been_scored: true }).count
    selections_without_scores = total_selections - selections_with_scores

    puts "Total selections made: #{total_selections}"
    puts "Selections in scored games: #{selections_with_scores}"
    puts "Selections in unscored games: #{selections_without_scores}"
    puts

    if selections_with_scores == 0
      puts "⚠️  No selections found in scored games. Cannot verify point calculations."
      exit 0
    end

    puts "DETAILED BREAKDOWN BY WEEK:"
    puts "-" * 40

    # Group selections by week
    weeks_data = {}
    user.selections.includes(:game).each do |selection|
      game = selection.game
      week_id = game.week_id
      week_number = game.week.week_number
      week_active = game.week.active
      
      weeks_data[week_id] ||= {
        week_number: week_number,
        week_active: week_active,
        selections: [],
        total_game_a_points: 0,
        total_game_b_points: 0,
        total_points: 0,
        games_scored: 0
      }
      
      weeks_data[week_id][:selections] << {
        game_id: game.id,
        week_number: week_number,
        home_team: game.home_team&.region,
        away_team: game.away_team&.region,
        pref_pick_team: selection.pref_pick_team,
        spread_pick_team: selection.spread_pick_team,
        pref_pick_int: selection.pref_pick_int,
        correct_pref_pick: selection.correct_pref_pick,
        correct_spread_pick: selection.correct_spread_pick,
        has_game_been_scored: game.has_game_been_scored,
        tie_game: game.tie_game
      }
      
      if game.has_game_been_scored?
        weeks_data[week_id][:games_scored] += 1
        
        # Calculate points for this selection
        game_a_points = 0
        game_b_points = 0
        
        if selection.correct_pref_pick == true
          game_a_points = selection.pref_pick_int
          weeks_data[week_id][:total_game_a_points] += game_a_points
        end
        
        if selection.correct_spread_pick == true
          game_b_points = 7
          weeks_data[week_id][:total_game_b_points] += game_b_points
        end
        
        weeks_data[week_id][:total_points] += (game_a_points + game_b_points)
      end
    end

    # Sort by week number
    weeks_data.sort_by { |_, data| data[:week_number].to_i }.each do |week_id, data|
      puts "Week #{data[:week_number]} (#{data[:week_active] ? 'ACTIVE' : 'CLOSED'}):"
      puts "  Games scored: #{data[:games_scored]}/#{data[:selections].count}"
      puts "  Game A points: #{data[:total_game_a_points]}"
      puts "  Game B points: #{data[:total_game_b_points]}"
      puts "  Total week points: #{data[:total_points]}"
      
      data[:selections].each do |selection|
        status = selection[:has_game_been_scored] ? 
          "#{selection[:correct_pref_pick] ? '✅' : '❌'}A, #{selection[:correct_spread_pick] ? '✅' : '❌'}B" : 
          "⏳ Pending"
        
        puts "    Game #{selection[:game_id]}: #{selection[:home_team]} vs #{selection[:away_team]}"
        puts "      Pref: #{selection[:pref_pick_team]} (#{selection[:pref_pick_int]}pts) | Spread: #{selection[:spread_pick_team]}"
        puts "      Result: #{status}"
      end
      puts
    end

    puts "STEP 4: CALCULATED TOTALS"
    puts "-" * 40

    calculated_weekly_game_a = 0
    calculated_weekly_game_b = 0
    calculated_weekly_total = 0
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

    puts "Calculated from selections:"
    puts "  weekly_points_game_a: #{calculated_weekly_game_a}"
    puts "  weekly_points_game_b: #{calculated_weekly_game_b}"
    puts "  weekly_points: #{calculated_weekly_total}"
    puts "  cumulative_points: #{calculated_cumulative}"
    puts

    puts "Stored in database:"
    puts "  weekly_points_game_a: #{user.weekly_points_game_a}"
    puts "  weekly_points_game_b: #{user.weekly_points_game_b}"
    puts "  weekly_points: #{user.weekly_points}"
    puts "  cumulative_points: #{user.cumulative_points}"
    puts

    puts "STEP 5: VERIFICATION RESULTS"
    puts "-" * 40

    discrepancies = []
    
    if user.weekly_points_game_a != calculated_weekly_game_a
      discrepancies << "Game A points: stored=#{user.weekly_points_game_a}, calculated=#{calculated_weekly_game_a}"
    end
    
    if user.weekly_points_game_b != calculated_weekly_game_b
      discrepancies << "Game B points: stored=#{user.weekly_points_game_b}, calculated=#{calculated_weekly_game_b}"
    end
    
    if user.weekly_points != calculated_weekly_total
      discrepancies << "Weekly total: stored=#{user.weekly_points}, calculated=#{calculated_weekly_total}"
    end
    
    if user.cumulative_points != calculated_cumulative
      discrepancies << "Cumulative: stored=#{user.cumulative_points}, calculated=#{calculated_cumulative}"
    end

    if discrepancies.empty?
      puts "✅ ALL SCORES ARE CORRECT!"
      puts "All point totals match the calculated values from selections."
    else
      puts "❌ DISCREPANCIES FOUND:"
      discrepancies.each { |discrepancy| puts "  - #{discrepancy}" }
      puts
      puts "🔧 TO FIX:"
      puts "  Run 'rake fix:all_points' to correct all point totals."
    end

    puts
    puts "=" * 80
    puts "VERIFICATION COMPLETE"
    puts "=" * 80
  end

  desc "List all users for verification"
  task list_users: :environment do
    puts "=" * 80
    puts "AVAILABLE USERS"
    puts "=" * 80
    
    User.all.each do |user|
      puts "#{user.username} (ID: #{user.id}, Active: #{user.active})"
    end
    
    puts "=" * 80
    puts "Usage: rake verify:user_selections[username]"
    puts "Example: rake verify:user_selections[Aconrad57]"
    puts "=" * 80
  end
end

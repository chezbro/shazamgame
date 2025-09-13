namespace :fix do
  desc "Fix the scoring logic issues in the Game model"
  task scoring_logic: :environment do
    puts "=" * 80
    puts "FIX SCORING LOGIC"
    puts "=" * 80
    puts "Running at: #{Time.current}"
    puts "Environment: #{Rails.env}"
    puts "=" * 80

    puts "This will create a backup of the current Game model and show you the fixed tally_points method."
    puts

    # Create backup of current Game model
    backup_file = "game_model_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.rb"
    backup_path = Rails.root.join("lib", "backups", backup_file)
    
    # Ensure backup directory exists
    FileUtils.mkdir_p(File.dirname(backup_path))
    
    # Read current Game model
    game_model_path = Rails.root.join("app", "models", "game.rb")
    current_content = File.read(game_model_path)
    
    # Create backup
    File.write(backup_path, current_content)
    puts "✅ Backup created: #{backup_file}"
    puts

    puts "STEP 1: IDENTIFIED ISSUES"
    puts "-" * 40
    puts "❌ Issue 1: Double counting in tie games"
    puts "❌ Issue 2: Missing weekly_points update in Game A logic"
    puts "❌ Issue 3: Inconsistent weekly_points calculation"
    puts

    puts "STEP 2: PROPOSED FIX"
    puts "-" * 40
    puts "Here's the corrected tally_points method:"
    puts

    fixed_method = <<~RUBY
def tally_points
  Rails.logger.info "Tallying points for game #{id} (#{bowl_game_name if week&.bowl_game?})"
  Rails.logger.info "Team that won straight up: #{self.team_that_won_straight_up}"
  Rails.logger.info "Team that covered spread: #{self.team_that_covered_spread}"
  
  User.all.each do |user|
    user.selections.each do |selection|
      if selection.game_id == self.id && selection.game.week.id == self.week.id
        Rails.logger.info "Processing selection for user #{user.id} (#{user.username})"
        Rails.logger.info "Selection pref pick team: #{selection.pref_pick_team}"
        Rails.logger.info "Selection spread pick team: #{selection.spread_pick_team}"
        
        # Initialize points for this game
        game_a_points = 0
        game_b_points = 0
        
        # Handle tie games first (special case)
        if self.tie_game == true
          # In tie games, both Game A and Game B get points
          game_a_points = selection.pref_pick_int
          game_b_points = 7
          selection.correct_pref_pick = true
          selection.correct_spread_pick = true
          Rails.logger.info "Game was a tie, user #{user.username} gets both Game A and Game B points"
        else
          # Regular game logic
          
          # Game A: Preference pick (straight up winner)
          if selection.pref_pick_team == self.team_that_won_straight_up
            game_a_points = selection.pref_pick_int
            selection.correct_pref_pick = true
            Rails.logger.info "User #{user.username} got pref pick correct"
          else
            selection.correct_pref_pick = false
            Rails.logger.info "User #{user.username} got pref pick incorrect"
          end
          
          # Game B: Spread pick
          if self.team_that_covered_spread.nil? && !self.tie_game
            # Push (tie) on spread - both teams get points
            game_b_points = 7
            selection.correct_spread_pick = true
            Rails.logger.info "User #{user.username} got spread pick correct (push)"
          elsif selection.spread_pick_team == self.team_that_covered_spread
            game_b_points = 7
            selection.correct_spread_pick = true
            Rails.logger.info "User #{user.username} got spread pick correct"
          else
            selection.correct_spread_pick = false
            Rails.logger.info "User #{user.username} got spread pick incorrect"
          end
        end
        
        # Calculate total points for this game
        total_game_points = game_a_points + game_b_points
        
        # Update user scores (FIXED: consistent updates)
        user.weekly_points_game_a += game_a_points
        user.weekly_points_game_b += game_b_points
        user.weekly_points += total_game_points  # FIXED: Now properly updated
        user.cumulative_points += total_game_points
        
        # Save changes
        selection.save!
        user.save!
        
        Rails.logger.info "Final points - Game A: #{game_a_points}, Game B: #{game_b_points}, Total: #{total_game_points}"
        Rails.logger.info "Final selection values - Pref: #{selection.correct_pref_pick}, Spread: #{selection.correct_spread_pick}"
      end
    end
  end
  
  # Mark game as scored
  self.has_game_been_scored = true
  self.save!
end
RUBY

    puts fixed_method
    puts

    puts "STEP 3: KEY FIXES APPLIED"
    puts "-" * 40
    puts "✅ Fix 1: Tie games now handled first to prevent double counting"
    puts "✅ Fix 2: Added missing user.weekly_points += total_game_points"
    puts "✅ Fix 3: Consistent point calculation (weekly_points = game_a + game_b)"
    puts "✅ Fix 4: Cleaner logic flow with proper variable initialization"
    puts

    puts "STEP 4: NEXT STEPS"
    puts "-" * 40
    puts "To apply this fix:"
    puts "1. Review the proposed changes above"
    puts "2. If approved, manually update the tally_points method in app/models/game.rb"
    puts "3. Test the scoring with a sample game"
    puts "4. Run 'rake verify:scoring' to confirm the fix works"
    puts

    puts "⚠️  WARNING: This change affects live scoring logic!"
    puts "   Make sure to test thoroughly before deploying to production."
    puts

    puts "=" * 80
    puts "ANALYSIS COMPLETE"
    puts "=" * 80
  end
end

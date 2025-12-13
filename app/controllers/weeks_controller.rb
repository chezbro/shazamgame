class WeeksController < ApplicationController
  before_action :set_week, only: [:show, :edit, :update, :destroy]

  # GET /weeks
  # GET /weeks.json
  def index
    @weeks = Week.all.order(Arel.sql("CAST(week_number AS INTEGER), bowl_game DESC"))
    @game = Game.new
    @games = Game.where(week_id: 1).where(game_selected_by_admin: true)

  end

  # GET /weeks/1
  # GET /weeks/1.json
  def show
    @week = Week.find(params[:id])
    @game = Game.new
    @games = Game.where(week_id: params[:id]).where(game_selected_by_admin: true)
    # @games.each do |game|
    #   game.selections.each do |selection|
    #     @selection = selection
    #   end
    # end
  end

  # GET /weeks/new
  def new
    @team = Team.new
    @week = Week.new
    # Build maximum number of games (13) so form always has enough fields
    # JavaScript will show/hide based on number_of_games input
    13.times do
      games = @week.games.build
    end
  end

  # GET /weeks/1/edit
  def edit
    # Ensure we have at least 13 game fields for the form (JavaScript will show/hide based on number_of_games)
    # This ensures the form always has enough fields even if the week has fewer games
    current_games = @week.games.count
    if current_games < 13
      (13 - current_games).times do
        @week.games.build
      end
    end
  end

  # POST /weeks
  # POST /weeks.json
  def create
    # Convert checkbox array to comma-separated string if present
    if params[:week] && params[:week][:available_points_checkboxes].present?
      params[:week][:available_points] = params[:week][:available_points_checkboxes].sort { |a, b| b.to_i <=> a.to_i }.join(',')
      params[:week].delete(:available_points_checkboxes) # Remove the non-attribute parameter
    end
    
    # Filter out empty games (games without teams/spreads) before creating
    # This prevents validation errors for hidden games that weren't filled in
    if params[:week] && params[:week][:games_attributes].present?
      filtered_games = {}
      params[:week][:games_attributes].each do |key, game_attrs|
        # Only include games that have at least one field filled (home_team, away_team, or spread)
        unless game_attrs[:home_team_id].blank? && game_attrs[:away_team_id].blank? && game_attrs[:spread].blank?
          filtered_games[key] = game_attrs
        end
      end
      params[:week][:games_attributes] = filtered_games
    end
    
    @week = Week.new(week_params)
    @team = Team.new # needed for the form

    respond_to do |format|
      if @week.save
        week_number = Week.all.count.to_s
        @week.week_number = week_number
        
        # Adjust number of games based on number_of_games after initial save
        current_game_count = @week.games.reload.count
        target_game_count = @week.number_of_games || 13
        
        if current_game_count < target_game_count
          # Add more games
          (target_game_count - current_game_count).times do
            @week.games.create(active: true, has_game_been_scored: false, game_selected_by_admin: true)
          end
        elsif current_game_count > target_game_count
          # Remove extra games (prefer removing games without teams selected)
          games_to_remove_count = current_game_count - target_game_count
          empty_games = @week.games.where(home_team_id: nil, away_team_id: nil)
          empty_games_count = empty_games.count
          
          if empty_games_count >= games_to_remove_count
            # Remove enough empty games
            empty_games.limit(games_to_remove_count).destroy_all
          else
            # Remove all empty games, then remove from the end if needed
            empty_games.destroy_all
            remaining_to_remove = games_to_remove_count - empty_games_count
            if remaining_to_remove > 0
              @week.games.order(:id).last(remaining_to_remove).each(&:destroy)
            end
          end
        end
        
        if @week.bowl_game
          # For bowl weeks, keep other bowl weeks active
          # Only deactivate regular season weeks
          Week.where(active: true, bowl_game: false).each do |week|
            week.active = false
            week.save!
          end
        else
          # For regular season weeks, deactivate all other weeks
          Week.where(active: true).each do |week|
            week.active = false
            week.save!
          end
        end

        @week.active = true
        @week.save!

        # Add this section to ensure games are properly set up
        @week.games.each do |game|
          game.active = true
          game.has_game_been_scored = false
        end
        @week.save!

        # Only remove extra game if it wasn't properly associated
        last_game = Game.last
        if last_game && last_game.week_id.nil?
          last_game.delete
        end

        format.html { redirect_to root_url, notice: "New Week successfully created" }
        format.json { head :no_content }
      else
        # Render the form again with errors
        format.html { 
          render :new, 
          alert: "Unable to create week: #{@week.errors.full_messages.join(', ')}" 
        }
        format.json { render json: @week.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weeks/1
  # PATCH/PUT /weeks/1.json
  def update
    # Convert checkbox array to comma-separated string if present
    if params[:week] && params[:week][:available_points_checkboxes].present?
      params[:week][:available_points] = params[:week][:available_points_checkboxes].sort { |a, b| b.to_i <=> a.to_i }.join(',')
      params[:week].delete(:available_points_checkboxes) # Remove the non-attribute parameter
    end
    
    # Filter out empty games (games without teams/spreads) before updating
    # This prevents validation errors for hidden games that weren't filled in
    if params[:week] && params[:week][:games_attributes].present?
      filtered_games = {}
      params[:week][:games_attributes].each do |key, game_attrs|
        # Keep games marked for destruction
        if game_attrs[:_destroy] == '1' || game_attrs[:_destroy] == 'true'
          filtered_games[key] = game_attrs
        # Keep existing games (they have an id)
        elsif game_attrs[:id].present?
          filtered_games[key] = game_attrs
        # Only include new games that have at least one field filled
        elsif game_attrs[:home_team_id].present? || game_attrs[:away_team_id].present? || game_attrs[:spread].present?
          filtered_games[key] = game_attrs
        end
        # Otherwise, skip empty new games
      end
      params[:week][:games_attributes] = filtered_games
    end
    
    respond_to do |format|
      if @week.update(week_params)
        # Adjust number of games based on number_of_games after update
        current_game_count = @week.games.reload.count
        target_game_count = @week.number_of_games || 13
        
        if current_game_count < target_game_count
          # Add more games
          (target_game_count - current_game_count).times do
            @week.games.create(active: true, has_game_been_scored: false, game_selected_by_admin: true)
          end
        elsif current_game_count > target_game_count
          # Remove extra games (prefer removing games without teams selected)
          games_to_remove_count = current_game_count - target_game_count
          empty_games = @week.games.where(home_team_id: nil, away_team_id: nil)
          empty_games_count = empty_games.count
          
          if empty_games_count >= games_to_remove_count
            # Remove enough empty games
            empty_games.limit(games_to_remove_count).destroy_all
          else
            # Remove all empty games, then remove from the end if needed
            empty_games.destroy_all
            remaining_to_remove = games_to_remove_count - empty_games_count
            if remaining_to_remove > 0
              @week.games.order(:id).last(remaining_to_remove).each(&:destroy)
            end
          end
        end
        
        format.html { redirect_to @week, notice: 'Week was successfully updated.' }
        format.json { render :show, status: :ok, location: @week }
      else
        format.html { render :edit }
        format.json { render json: @week.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weeks/1
  # DELETE /weeks/1.json
  def destroy
    @week.destroy
    respond_to do |format|
      format.html { redirect_to weeks_url, notice: 'Week was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def close_week
    @week = Week.find(params[:id])
    
    if @week.update(active: false)
      # Save current weekly scores to last_week_score before resetting
      User.set_weekly_points_to_zero
      redirect_to weeks_path, notice: "Week #{@week.week_number} #{@week.bowl_game? ? '(Bowl Games)' : ''} has been closed."
    else
      redirect_to weeks_path, alert: "Error closing week."
    end
  end

  def reset_week
    @week = Week.find(params[:id])
    
    # Reset user points for this specific week only
    User.all.each do |u|
      u.cumulative_points = u.cumulative_points - u.weekly_points
      u.weekly_points = 0
      u.weekly_points_game_a = 0
      u.weekly_points_game_b = 0
      u.save!
    end

    # Reset only games in this specific week
    Game.where(week_id: @week.id).each do |g|
      g.has_game_been_scored = false
      g.active = true
      g.team_that_won_straight_up = nil
      g.team_that_covered_spread = nil
      g.away_team_won_straight_up = nil
      g.home_team_won_straight_up = nil
      g.home_team_score = nil
      g.away_team_score = nil
      g.save!
    end

    # Reset selections for this specific week
    Selection.joins(:game).where(games: { week_id: @week.id }).each do |selection|
      selection.correct_pref_pick = nil
      selection.correct_spread_pick = nil
      selection.save!
    end

    redirect_to week_path(@week), notice: "Week #{@week.week_number} has been reset successfully!"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_week
      @week = Week.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def week_params
      params.require(:week).permit(
        :bowl_game,
        :week_number,
        :active,
        :year,
        :number_of_games,
        :available_points,
        games_attributes: [
          :id,
          :home_team_id,
          :away_team_id,
          :home_team_spread,
          :spread,
          :game_selected_by_admin,
          :active,
          :bowl_game_name
        ]
      )
    end

end

class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:index, :show]

  before_action :require_user_signed_in, only: [:new, :edit, :create, :game_update, :update, :destroy]

  before_action :set_game, only: [:show, :edit, :update, :destroy]

  before_action :set_game_to_be_updated, only: [:game_update]

  # GET /games
  # GET /games.json

  def index
    # Find all active weeks
    @active_weeks = Week.where(active: true)
    
    if @active_weeks.empty?
      @active_weeks = [Week.last] if Week.last.present?
    end
    
    # Set @week to the first active week (or last week if no active weeks)
    @week = @active_weeks.first
    
    # Get games for all active weeks that haven't been scored
    @games = Game.where(week_id: @active_weeks.pluck(:id))
             .where(game_selected_by_admin: true)
             .where(has_game_been_scored: false)
             .includes(:week) # Eager load weeks to avoid N+1 queries
             .order("weeks.week_number DESC") # Order by week number descending
             
    Rails.logger.info "Active weeks: #{@active_weeks&.map(&:week_number)}"
    Rails.logger.info "Week: #{@week&.week_number}"
    Rails.logger.info "Games count: #{@games&.count}"
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @games = Game.where(week_id: params[:id]).where(game_selected_by_admin: true)
    @selection = Selection.where(game_id: params[:id]).where(user_id: current_user) || Selection.new
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    # @game = Game.new(game_params)
    @game.user = current_user
    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    @game = Game.find(params[:id])
    
    respond_to do |format|
      if @game.update(game_params)
        # Reset game if it was previously scored
        if @game.has_game_been_scored?
          @game.game_reset
        end
        
        begin
          @game.check_selection_and_tally_points
          @game.has_game_been_scored = true
          @game.save!

          format.html { redirect_to week_path(@game.week), notice: 'Scores updated successfully.' }
          format.json { render :show, status: :ok, location: @game }
        rescue => e
          Rails.logger.error "Error updating game scores: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          format.html { 
            redirect_to week_path(@game.week), 
            alert: "Unable to update scores: #{e.message}" 
          }
          format.json { render json: { error: e.message }, status: :unprocessable_entity }
        end
      else
        Rails.logger.error "Game update failed: #{@game.errors.full_messages.join(', ')}"
        format.html { 
          redirect_to week_path(@game.week), 
          alert: "Unable to update scores: #{@game.errors.full_messages.join(', ')}" 
        }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def game_update
    respond_to do |format|

      if @game.update(game_params)
        
        format.html { redirect_to games_path, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: games_path }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end


def team_selections
  @game = Game.find(params[:game_id].to_i)
end

def home_team_selections
  @game = Game.find(params[:game_id].to_i)
end

def away_team_selections
  @game = Game.find(params[:game_id].to_i)
end

def reset_the_week
  # Find the active week first
  active_week = Week.where(active: true).first
  if active_week.nil?
    redirect_to root_url, alert: 'No active week found!'
    return
  end

  # Reset user points for the active week only
  User.all.each do |u|
    u.cumulative_points = u.cumulative_points - u.weekly_points
    u.weekly_points = 0
    u.weekly_points_game_a = 0
    u.weekly_points_game_b = 0
    u.save!
  end

  # Reset only games in the active week
  Game.where(week_id: active_week.id).each do |g|
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

  # Reset selections for the active week
  Selection.joins(:game).where(games: { week_id: active_week.id }).each do |selection|
    selection.correct_pref_pick = nil
    selection.correct_spread_pick = nil
    selection.save!
  end

  respond_to do |format|
    format.html { redirect_to week_path(active_week), notice: "Week #{active_week.week_number} has been reset successfully!" }
    format.json { head :no_content }
  end
end

  def game_reset
    @game = Game.find(params[:game].to_i)
    @game.game_reset
    @game.has_game_been_scored = false
    @game.save!
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'Game has been Reset.' }
      format.json { head :no_content }
    end
  end

  def hide_and_unhide
    @weeks = Week.where(active: false)
    @week = Week.last if Week.last.present?
  end

  def hide_games
    g = Game.where(id:params[:game].to_i).first
    g.hidden = true
    g.save!
    respond_to do |format|
      format.html { redirect_to hide_and_unhide_path, alert: 'Game is now invisible' }
      format.json { head :no_content }
    end
  end

  def unhide_games
    g = Game.where(id:params[:game].to_i).first
    g.hidden = false
    g.save!
    respond_to do |format|
      format.html { redirect_to hide_and_unhide_path, alert: 'Game is now visible' }
      format.json { head :no_content }
    end
  end

  def enable_picks
    Game.where(active: false).each do |game|
      game.active = true
      game.save!
    end
    respond_to do |format|
      format.html { redirect_to games_url, alert: 'Selections Now Disabled.' }
      format.json { head :no_content }
    end
  end

  def disable_picks
    Game.where(active: true).each do |game|
      game.active = false
      game.save!
    end
    respond_to do |format|
      format.html { redirect_to games_url, alert: 'Selections Now Disabled.' }
      format.json { head :no_content }
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def player_selections
    # Find all active weeks
    @active_weeks = Week.where(active: true)
    
    # Get games for all active weeks that haven't been scored yet
    @games = Game.where(week_id: @active_weeks.pluck(:id))
               .where(game_selected_by_admin: true)
               .where(has_game_been_scored: false)
               .includes(:week)
    
    Rails.logger.info "Active weeks: #{@active_weeks.map(&:week_number)}"
    Rails.logger.info "Games count: #{@games&.count}"
  end

  def restore_week1_scores
    # Restore Week 1 scores that were accidentally reset
    week1 = Week.find_by(week_number: 1)
    if week1.nil?
      redirect_to root_url, alert: 'Week 1 not found!'
      return
    end

    games = Game.where(week_id: week1.id, game_selected_by_admin: true)
    
    games.each do |game|
      # Restore scores based on team names from your image
      if game.home_team&.region&.include?("Bucknell") && game.away_team&.region&.include?("Buffalo")
        game.home_team_score = 12
        game.away_team_score = 20
      elsif game.home_team&.region&.include?("Elon") && game.away_team&.region&.include?("Fresno")
        game.home_team_score = 21
        game.away_team_score = 19
      else
        next
      end
      
      # Score the game
      begin
        game.check_selection_and_tally_points
      rescue => e
        Rails.logger.error "Error scoring game #{game.id}: #{e.message}"
      end
    end

    redirect_to week_path(week1), notice: 'Week 1 scores restored successfully!'
  end

  def force_score_active_week
    # Force score all games in the active week
    active_week = Week.where(active: true).first
    if active_week.nil?
      redirect_to root_url, alert: 'No active week found!'
      return
    end

    games = Game.where(week_id: active_week.id, game_selected_by_admin: true)
    scored_count = 0
    
    games.each do |game|
      if game.home_team_score.present? && game.away_team_score.present?
        begin
          # Reset game if it was previously scored to avoid duplicate points
          if game.has_game_been_scored?
            game.game_reset
          end
          
          game.check_selection_and_tally_points
          scored_count += 1
        rescue => e
          Rails.logger.error "Error scoring game #{game.id}: #{e.message}"
        end
      end
    end

    redirect_to week_path(active_week), notice: "Force scored #{scored_count} games in Week #{active_week.week_number}!"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end
    def set_game_to_be_updated
      @game = Game.find(params[:game][:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(
        :home_team_score, 
        :away_team_score,
        :has_game_been_scored,
        :bowl_game_name,
        :team_that_won_straight_up,
        :team_that_covered_spread,
        :home_team_won_straight_up,
        :away_team_won_straight_up,
        :tie_game,
        :active,
        :spread,
        :week_id,
        :home_team_id,
        :away_team_id,
        selections_attributes: [
          :id,
          :pref_pick_team,
          :pref_pick_int,
          :spread_pick_team,
          :user_id,
          :game_id,
          :week_id
        ]
      )
    end
end

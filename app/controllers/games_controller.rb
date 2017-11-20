class GamesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:index, :show]

  before_filter :require_user_signed_in, only: [:new, :edit, :create, :update, :destroy]

  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json

  def index
    @weeks = Week.where(active: false)
    @week = Week.last if Week.last.present?
    # @selection = Selection.new
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
    respond_to do |format|
      if @game.update(game_params)
        @game.check_selection_and_tally_points
        @game.tally_points
        # dont want to reset the total_weekly_points, want to preserve them and only delete when she scores game winners
        @game.has_game_been_scored = true
        @game.save!
        @game.reload
        format.html { redirect_to Week.last, notice: 'Score was successfully added.' }
      else
        flash[:success] = "Error"
        format.html { redirect_to(:back) }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:week_id, :user_id, :points, :is_home_team, :spread, :home_team_id, :away_team_id, :home_team_pref_pick, :away_team_pref_pick, :home_team_spread_pick, :away_team_spread_pick, :home_team_covered_spread, :away_team_covered_spread, :tie_game, :game_selected_by_admin, :home_team_score, :away_team_score, :home_team_won_straight_up, :away_team_won_straight_up, :team_that_won_straight_up, :team_that_covered_spread, selections_attributes: [:id, :pref_pick_team, :pref_pick_int, :spread_pick_team, :user_id, :game_id])
    end
end

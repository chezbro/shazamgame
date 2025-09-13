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
    # Build n-games for dev
    if Rails.env.development?
      2.times do
        games = @week.games.build
      end
    else
      # Build n-games for prod
      13.times do
        games = @week.games.build
      end
    end
  end

  # GET /weeks/1/edit
  def edit
  end

  # POST /weeks
  # POST /weeks.json
  def create
    @week = Week.new(week_params)
    @team = Team.new # needed for the form

    respond_to do |format|
      if @week.save
        week_number = Week.all.count.to_s
        @week.week_number = week_number
        
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
    respond_to do |format|
      if @week.update(week_params)
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

class WeeksController < ApplicationController
  before_action :set_week, only: [:show, :edit, :update, :destroy]

  # GET /weeks
  # GET /weeks.json
  def index
    @weeks = Week.all
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
    # Build 13 games
    if Rails.env.development?
      3.times do 
        games = @week.games.build
      end
    else
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
    @week.games.new(params[:games_attributes])
    # extra game is created above

    respond_to do |format|
      if @week.save
        week_number = Week.all.count.to_s
        @week.week_number = week_number
        User.set_weekly_points_to_zero
        Week.where(active: true).each do |week|
          week.active = false
          week.save!
        end
        @week.active = true
        @week.save!
        # @week.week_number = 
        Game.last.delete
        # User.delete_weekly_points
        format.html { redirect_to root_url, notice: "New Week successfully created" }
        format.json { head :no_content }
      else
        format.html { redirect_to root_url, notice: "Unable to Create Week" }
        format.json { head :no_content }
      end
    end

    # respond_to do |format|
    #   if @week.save
    #     format.html { redirect_to @week, notice: 'Week was successfully created.' }
    #     format.json { render :show, status: :created, location: @week }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @week.errors, status: :unprocessable_entity }
    #   end
    # end
    
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_week
      @week = Week.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def week_params
      params.require(:week).permit(:week_number, :active, :year, :year_in_datetime, games_attributes: [:id , :home_team_id, :away_team_id,:home_team_spread, :spread, :game_selected_by_admin, :active ])
    end

end

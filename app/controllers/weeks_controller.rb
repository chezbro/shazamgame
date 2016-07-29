class WeeksController < ApplicationController
  before_action :set_week, only: [:show, :edit, :update, :destroy]

  # GET /weeks
  # GET /weeks.json
  def index
    @week = Week.new
    @games = Game.where(week_id: 1).where(game_selected_by_admin: true)
    @weeks = Week.all
  end

  # GET /weeks/1
  # GET /weeks/1.json
  def show
    @week = Week.find(params[:id])
    @games = Game.where(week_id: 1).where(game_selected_by_admin: true)
  end

  # GET /weeks/new
  def new
    @week = Week.new
    # Build 13 games
    13.times do 
      games = @week.games.build
    end


  end

  # GET /weeks/1/edit
  def edit
  end

  # POST /weeks
  # POST /weeks.json
  def create

    params["games"].each do |game|
      Game.create(game_params(game))
    end
    respond_to do |format|
      format.html { redirect_to weeks_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
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
      params.require(:week).permit(:week_number, :year, :year_in_datetime)
    end
end

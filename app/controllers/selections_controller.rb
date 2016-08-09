class SelectionsController < ApplicationController
  before_action :set_selection, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token

  # GET /selections
  # GET /selections.json
  def index
    @selections = Selection.all

  end

  # GET /selections/1
  # GET /selections/1.json
  def show
    @weeks = Week.all
    @selection = Selection.new
    @selections = Selection.where(user_id: current_user)
    @games = Game.where(week_id: Week.last.id).where(game_selected_by_admin: true)
  end

  # GET /selections/new
  def new
    @games = Game.where(week_id: 1).where(game_selected_by_admin: true)
    @selection = Selection.new
  end

  # GET /selections/1/edit
  def edit
  end

  # POST /selections
  # POST /selections.json
  def create
    @selection = Selection.new(selection_params)
    respond_to do |format|
      if @selection.save
        format.html { redirect_to games_url, notice: "Selection successfully created" }
        format.json { head :no_content }
      else
        format.html { redirect_to selection_path(Week.last), notice: @selection.errors }
        format.json { render json: @selection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /selections/1
  # PATCH/PUT /selections/1.json
  def update
    respond_to do |format|
      if @selection.update(selection_params)
        format.html { redirect_to @selection, notice: 'Selection was successfully updated.' }
        format.json { render :show, status: :ok, location: @selection }
      else
        format.html { redirect_to selection_path(@selection), notice: @selection.errors }
        format.json { render json: @selection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /selections/1
  # DELETE /selections/1.json
  def destroy
    @selection.destroy
    respond_to do |format|
      format.html { redirect_to selections_url, notice: 'Selection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_selection
      @selection = Selection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def selection_params
      params.require(:selection).permit(:id, :game_id, :user_id, :points, :pref_pick_int, :pref_pick_str, :spread_pick, :pref_pick_team, :spread_pick_team)
    end
end

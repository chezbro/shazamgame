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
    @game = Game.find(params[:game_id])
    @games = Game.where(week_id: Week.last.id).where(game_selected_by_admin: true)
  end

  # GET /selections/new
  def new
    @game = Game.find(params[:game_id])
    @selection = Selection.new
  end

  # GET /selections/1/edit
  def edit
    @game = Game.find(params[:game_id].to_i)
    @selection = Selection.find(params[:id])
  end

  # POST /selections
  # POST /selections.json
  def create
    @selection = Selection.new(selection_params)
    # perhaps you can just manually find or create the Selection. If it exists, find it, if not, create a new one.
    respond_to do |format|
      if @selection.save
        format.html { redirect_to games_path, notice: "Selection successfully created" }
        format.json { head :no_content }
      else
        @game = Game.find(params[:game_id])
        format.html { redirect_to new_game_selection_path(@game, @selection), flash: {error: "Error: You must fill out each Selection."} }
        format.json { render json: @selection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /selections/1
  # PATCH/PUT /selections/1.json
  def update
    respond_to do |format|
        @game = Game.find(params[:game_id])
     if @selection.update(selection_params)
        @selection.save!
        @selection.reload
        format.html { redirect_to games_url,notice: 'Selection was successfully updated.' }
        format.json { render :show, status: :ok, location: @selection }
      else
        format.html { redirect_to new_game_selection_path(@game, @selection), flash: {error: "Error: You must fill out each Selection."} }
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

class SelectionsController < ApplicationController
  before_action :set_selection, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /selections
  # GET /selections.json
  def index
    if current_user.admin?
      @weeks = Week.order(id: :desc)
      Rails.logger.debug "Found weeks: #{@weeks.map { |w| "Week #{w.week_number} (ID: #{w.id})" }.join(', ')}"
      
      @selections = Selection.joins(:game)
                           .includes(:game, :user)
                           .where(games: { week_id: @weeks.pluck(:id) })
                           .order("games.week_id DESC, users.name, selections.pref_pick_int DESC")
      
      Rails.logger.debug "Found selections: #{@selections.count}"
      Rails.logger.debug "Weeks with selections: #{@selections.map { |s| s.game.week.week_number }.uniq.sort}"
    else
      @selections = Selection.where(user_id: current_user.id)
                           .joins(:game)
                           .includes(:game)
                           .order("games.week_id DESC, selections.pref_pick_int DESC")
    end
                         
    @selections_by_week = @selections.group_by { |s| s.game.week }
    Rails.logger.debug "Grouped weeks: #{@selections_by_week.keys.map(&:week_number).sort}"
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
    @week = Week.last
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
    if Selection.where(user_id: current_user).where(game_id: params[:selection][:game_id]).present?
      @selection = Selection.where(user_id: current_user).where(game_id: params[:selection][:game_id]).first
      @selection.assign_attributes(selection_params)
    else
      @selection = Selection.new(selection_params)
    end
    
    # Add debugging
    Rails.logger.debug "Creating selection: #{selection_params.inspect}"
    Rails.logger.debug "For game: #{Game.find(params[:selection][:game_id]).inspect}"
    Rails.logger.debug "In week: #{Game.find(params[:selection][:game_id]).week.inspect}"
    
    @errors = false
    @game = params[:selection][:game_id]
    Rails.logger.debug "Setting @game to: #{@game}"
    respond_to do |format|
      if @selection.save
        format.html
        format.js { flash.now[:notice] = "Selection successfully submitted." }
      else
        @errors = true
        error_message = @selection.errors.full_messages.first || "You must fill out each Selection."
        format.html
        format.js { flash.now[:notice] = "Error: #{error_message}" }
      end
    end
  end

  # PATCH/PUT /selections/1
  # PATCH/PUT /selections/1.json
  def update
    respond_to do |format|
        @game = Game.find(params[:game_id])
     if @selection.update(selection_params)
        format.js { flash.now[:notice] = "Selection successfully submitted." }
        # format.html { redirect_to games_path, :notice => "Selection has been saved successfully." }
      else
        error_message = @selection.errors.full_messages.first || "You must fill out each Selection."
        format.js { flash.now[:notice] = "Error: #{error_message}" }
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


  def reset_selections
    Selection.where(user_id: current_user).where(week_id: Week.last.id).destroy_all if Selection.where(user_id: current_user).where(week_id: Week.last.id).present?
    respond_to do |format|
      format.html { redirect_to games_path, notice: 'Selections have been reset.' }
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
      params.require(:selection).permit(:id, :game_id, :user_id, :week_id, :points, :pref_pick_int, :pref_pick_str, :spread_pick, :pref_pick_team, :spread_pick_team)
    end
end

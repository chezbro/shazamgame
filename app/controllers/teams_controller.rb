class TeamsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    team = Team.find_or_create_by(region: team_params[:region], name: team_params[:name])
    
    if team.persisted? && !team.new_record?
      notice_message = "Team already exists"
    else
      notice_message = "New Team successfully created"
    end

    respond_to do |format|
      format.html { redirect_to new_week_path, notice: notice_message }
    end
  end


  private

  def team_params
    params.require(:team).permit(:id, :region, :name)
  end

end
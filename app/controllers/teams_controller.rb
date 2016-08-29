class TeamsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    Team.create(team_params)

    respond_to do |format|
        format.html { redirect_to new_week_path, notice: "New Team successfully created" }
      end
  end


  private

  def team_params
    params.require(:team).permit(:id, :region, :name)
  end

end
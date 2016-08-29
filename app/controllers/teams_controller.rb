class TeamsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    Team.create(team_params)

    respond_to do |format|
        format.js { flash.now[:notice] = "Team successfully added." }
      end
  end


  private

  def team_params
    params.require(:team).permit(:id, :region, :name)
  end

end
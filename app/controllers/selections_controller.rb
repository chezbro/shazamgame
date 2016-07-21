class SelectionsController < InheritedResources::Base

  private

    def selection_params
      params.require(:selection).permit(:game_id, :user_id, :correct, :admin)
    end
end


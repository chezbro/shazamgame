class AnnouncementsController < ApplicationController
  # before_action :disable_navbar, only: [:index]

  def new
    @announcement = Announcement.new
    @announcements = Announcement.where(saved: nil).order("created_at DESC")
    @saved_announcements = Announcement.where(saved: true).order("created_at DESC")
  end
  
  def create
    @announcement = Announcement.new(announcement_params)
  
    respond_to do |format|
      if @announcement.save
        format.html { redirect_to root_url, notice: 'Your Announcement was created successfully and can now be seen below.' }
      else
        flash[:alert] = "Whoops. Something went wrong, try again."
        format.html { render :new }
      end
    end
  end
  

private

# Never trust parameters from the scary internet, only allow the white list through.
def announcement_params
  params.require(:announcement).permit(:body, :saved)
end

end


class Users::RegistrationsController < Devise::RegistrationsController
  # http_basic_authenticate_with :name => "shazam2019", :password => "shazam2019", only: :new
  include ApplicationHelper
  prepend_before_action :check_captcha, only: [:create]


    def create
      if verify_recaptcha
        super
      else
        build_resource(sign_up_params)
        clean_up_passwords(resource)
        flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
        flash.delete :recaptcha_error
        redirect_to root_url
      end
    end


  def new
    super
  end

  def edit
    super
  end
end



  private
  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) { redirect_to :back }
    end 
  end


  end
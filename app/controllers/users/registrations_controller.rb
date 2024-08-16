class Users::RegistrationsController < Devise::RegistrationsController
  # http_basic_authenticate_with :name => "shazam2019", :password => "shazam2019", only: :new
  include ApplicationHelper
  prepend_before_action :check_captcha, only: [:create]

  def create
    def create
      if verify_recaptcha
        super
      else
        build_resource(sign_up_params)
        clean_up_passwords(resource)
        flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
        flash.delete :recaptcha_error
        render :new
      end
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
    return if verify_recaptcha # verify_recaptcha(action: 'signup') for v3

    self.resource = resource_class.new sign_up_params
    resource.validate # Look for any other validation errors besides reCAPTCHA
    set_minimum_password_length

    respond_with_navigational(resource) do
     flash.discard(:recaptcha_error) # We need to discard flash to avoid showing it on the next page reload
      render :new
    end
  end
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  
  protect_from_forgery with: :null_session

  before_action :configure_permitted_parameters, if: :devise_controller?

  
  def disable_navbar
    @disable_navbar = true
  end

  protected

  #->Prelang (user_login:devise)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up)        { |u| u.permit(:username, :email, :password, :password_confirmation, :cell_phone_number, :address, :fav_teams, :remember_me, :name, :nickname) }
    devise_parameter_sanitizer.permit(:sign_in)        { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :cell_phone_number, :address, :fav_teams,  :current_password) }
  end


  private
  
  #-> Prelang (user_login:devise)
  def require_user_signed_in
    unless user_signed_in?

      # If the user came from a page, we can send them back.  Otherwise, send
      # them to the root path.
      if request.env['HTTP_REFERER']
        fallback_redirect = :back
      elsif defined?(root_path)
        fallback_redirect = root_path
      else
        fallback_redirect = "/"
      end

      redirect_to fallback_redirect, flash: {error: "You must be signed in to view this page."}
    end
  end

end



# def configure_permitted_parameters
#   devise_parameter_sanitizer.permit(:sign_up) do |user_params|
#     user_params.permit({ roles: [] }, :email, :password, :password_confirmation, :username, :nickname, :name)
#   end
# end
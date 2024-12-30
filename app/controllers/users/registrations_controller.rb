class Users::RegistrationsController < Devise::RegistrationsController
  # http_basic_authenticate_with :name => "shazam2019", :password => "shazam2019", only: :new

  include ApplicationHelper

  def create
    super
  end

  def new
    super
  end

  def edit
    super
  end

  # Add this method to skip current password validation
  protected
  
  def update_resource(resource, params)
    # If password is blank, update without password
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
      resource.update_without_password(params)
    else
      # If password is present, use update_attributes to properly handle password update
      resource.update(params)
    end
  end
end

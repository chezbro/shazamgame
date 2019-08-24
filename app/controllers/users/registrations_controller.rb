class Users::RegistrationsController < Devise::RegistrationsController
  http_basic_authenticate_with :name => "shazam", :password => "shazam", only: :new

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
end

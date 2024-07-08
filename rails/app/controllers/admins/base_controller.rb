class Admins::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  private

    def authenticate_admin!
      redirect_to new_admin_session_url unless current_admin
    end
end

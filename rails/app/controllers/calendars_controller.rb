class CalendarsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  private

    def authenticate_user!
      redirect_to new_user_session_path unless current_user
    end
end

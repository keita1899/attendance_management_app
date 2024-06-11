class ApplicationController < ActionController::Base
  protected

  def after_sign_out_path_for(resource)
    if resource == :user
      new_user_session_path
    elsif resource == :admin
      new_admin_session_path
    end
  end
end

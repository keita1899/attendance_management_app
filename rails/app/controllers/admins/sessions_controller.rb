class Admins::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params

  def after_sign_in_path_for(resource)
    admins_root_path
  end

  protected

    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [:name, :password])
    end
end

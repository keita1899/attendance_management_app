class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def create
    super do |resource|
      if resource.errors.any?
        flash[:alert] = t("devise.registrations.user.failed")
      end
    end
  end

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:last_name, :first_name, :last_name_kana, :first_name_kana])
    end
end

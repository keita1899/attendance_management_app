class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.errors.any?
        flash[:alert] = t("devise.registrations.user.failed")
      end
    end
  end
end

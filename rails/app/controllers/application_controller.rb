class ApplicationController < ActionController::Base
  unless Rails.env.development?
    rescue_from StandardError, with: :render500
    rescue_from ActionController::InvalidAuthenticityToken, with: :render422
    rescue_from ActiveRecord::RecordNotFound, with: :render404
    rescue_from ActionController::RoutingError, with: :render404
  end

  def render404
    respond_to do |format|
      format.html { render template: "errors/not_found", status: :not_found }
      format.all { render nothing: true, status: :not_found }
    end
  end

  def render422
    respond_to do |format|
      format.html { render template: "errors/unprocessable_entity", status: :unprocessable_entity }
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end

  def render500(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html { render template: "errors/internal_server_error", status: :internal_server_error }
      format.all { render nothing: true, status: :internal_server_error }
    end
  end

  protected

    def after_sign_out_path_for(resource)
      if resource == :user
        new_user_session_path
      elsif resource == :admin
        new_admin_session_path
      end
    end
end

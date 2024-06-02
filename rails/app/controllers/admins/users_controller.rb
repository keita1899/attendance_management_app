class Admins::UsersController < Admins::BaseController
  layout "admin"

  def index
    @users = User.page(params[:page]).order("created_at DESC")
  end
end

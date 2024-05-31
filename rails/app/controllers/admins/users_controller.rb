class Admins::UsersController < ApplicationController
  layout 'admin'

  def index
    @users = User.page(params[:page]).order('created_at DESC')
  end
end

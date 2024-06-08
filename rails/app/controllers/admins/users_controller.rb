class Admins::UsersController < Admins::BaseController
  layout "admin"

  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.page(params[:page]).order("created_at DESC")
  end

  def edit
    @wage = @user.wage || @user.build_wage
  end

  def update
    if @user.wage.update(wage_params)
      redirect_to admins_users_path, notice: "ユーザー情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!

    redirect_to admins_users_path, notice: "ユーザーを削除しました", status: :see_other
  end

  private

    def set_user
      @user = User.preload(:wage).find(params[:id])
    end

    def wage_params
      params.require(:wage).permit(:weekday_rate, :weekend_rate)
    end
end

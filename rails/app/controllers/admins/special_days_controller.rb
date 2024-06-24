class Admins::SpecialDaysController < Admins::BaseController
  layout "admin"

  def index
    @special_days = SpecialDay.page(params[:page]).order("created_at DESC")
  end

  def new
    @special_day = SpecialDay.new
  end

  def create
    @special_day = SpecialDay.new(special_day_params)
    if @special_day.save
      redirect_to admins_special_days_path, notice: "特別日が作成されました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def special_day_params
      params.require(:special_day).permit(:start_date, :end_date, :description, :wage_increment, :allowance)
    end
end

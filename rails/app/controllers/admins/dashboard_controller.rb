class Admins::DashboardController < Admins::BaseController
  def index
    @attendances = Attendance.preload(:user).where(date: Date.current).page(params[:page]).order("created_at DESC")
  end
end

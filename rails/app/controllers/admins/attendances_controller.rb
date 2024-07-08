class Admins::AttendancesController < Admins::BaseController
  def index
    @attendances = Attendance.preload(:user).page(params[:page]).order("created_at DESC")
  end
end

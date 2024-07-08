class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attendance, only: [:show, :clock_in, :clock_out]

  def index
    @attended_dates = current_user.attended_dates
    target_month = AttendanceSummaryService.calculate_target_month(params[:start_date])
    @attendance_summary = AttendanceSummaryService.new(current_user, target_month)
    @start_date, @end_date = @attendance_summary.pay_period
    @special_days = SpecialDay.in_month(target_month)
  end

  def show
  end

  def clock_in
    @attendance.update!(clock_in_time: Time.current)
    flash[:notice] = "出勤しました"
    redirect_back(fallback_location: root_path)
  end

  def clock_out
    @attendance.update!(clock_out_time: Time.current)
    @attendance.update_attendance_data
    flash[:notice] = "退勤しました"
    redirect_back(fallback_location: root_path)
  end

  private

    def set_attendance
      @date = Date.parse(params[:date])
      @special_day = SpecialDay.for_date(@date)
      @attendance = Attendance.find_or_initialize_by(user_id: current_user.id, date: @date, special_day: @special_day.present?)
      logger.debug @attendance.special_day
    end
end

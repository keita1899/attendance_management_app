class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attendance, only: [:show, :clock_in, :clock_out]

  def index
  end

  def show
    unless @attendance
      @attendance = Attendance.new(user_id: current_user.id, date: @date)
    end

    render "show"
  end

  def clock_in
    if @attendance
      @attendance.update!(clock_in_time: Time.current)
    else
      @attendance = Attendance.new(user_id: current_user.id, date: @date, clock_in_time: Time.current)
      @attendance.save!
    end
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
      @attendance = Attendance.find_by(user_id: current_user.id, date: @date)
    end
end

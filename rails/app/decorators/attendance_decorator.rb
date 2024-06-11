class AttendanceDecorator < ApplicationDecorator
  delegate_all

  def is_today?
    object.date == Time.zone.today
  end

  def can_clock_in?
    current_time = Time.current
    current_time >= Time.current.change(hour: 9, min: 30) && !object.clock_in_time.present?
  end

  def can_clock_out?
    object.clock_in_time.present? && !object.clock_out_time.present?
  end
end

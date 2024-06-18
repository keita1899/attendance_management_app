class AttendanceDecorator < ApplicationDecorator
  delegate_all

  def today?
    object.date == Time.zone.today
  end

  def can_clock_in?
    current_time = Time.current
    current_time >= Time.current.change(hour: 9, min: 30) && object.clock_in_time.blank?
  end

  def can_clock_out?
    object.clock_in_time.present? && object.clock_out_time.blank?
  end

  def day_of_week(date)
    %w[日 月 火 水 木 金 土][date.wday]
  end
end

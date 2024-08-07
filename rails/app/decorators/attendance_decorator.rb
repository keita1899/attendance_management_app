class AttendanceDecorator < ApplicationDecorator
  delegate_all

  def today?
    object.date == Time.zone.today
  end

  def can_clock_in?
    current_time = Time.current
    current_time >= Time.current.change(hour: 9, min: 30) && object.clock_in_time.nil?
  end

  def can_clock_out?
    object.clock_in_time.present? && object.clock_out_time.nil?
  end

  def day_of_week(date)
    %w[日 月 火 水 木 金 土][date.wday]
  end

  def status
    if object.clock_in_time.nil?
      '<span class="badge bg-secondary">未出勤</span>'.html_safe
    elsif object.clock_out_time.nil?
      '<span class="badge bg-success">出勤中</span>'.html_safe
    else
      '<span class="badge bg-dark">退勤済</span>'.html_safe
    end
  end
end

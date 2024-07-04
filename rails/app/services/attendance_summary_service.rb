class AttendanceSummaryService
  include AttendanceSummaryCalculations

  attr_reader :start_date, :end_date

  def self.calculate_target_month(start_date_param)
    start_date = start_date_param.present? ? Date.parse(start_date_param) : Time.zone.today
    start_date.beginning_of_month
  end

  def initialize(user, target_month)
    @user = user
    @start_date, @end_date = calculate_pay_period(target_month)
    @attendances = fetch_attendances
  end

  def total_monthly_working_weekdays
    weekday_attendances.size
  end

  def total_monthly_working_weekends
    weekend_attendances.size
  end

  def total_monthly_working_special_days
    special_day_attendances.size
  end

  def pay_period
    [@start_date, @end_date]
  end

  private

    def fetch_attendances
      @user.attendances.
        where(date: @start_date..@end_date).
        where.not(clock_out_time: nil).
        select(:id, :date, :working_minutes, :overtime_minutes, :daily_wage, :overtime_pay, :allowance, :special_day)
    end

    def weekday_attendances
      @attendances.select {|attendance| ![0, 6].include?(attendance.date.wday) && !attendance.special_day }
    end

    def weekend_attendances
      @attendances.select {|attendance| [0, 6].include?(attendance.date.wday) && !attendance.special_day }
    end

    def special_day_attendances
      @attendances.select(&:special_day)
    end

    def calculate_pay_period(target_month)
      year = target_month.year
      month = target_month.month

      start_date = Date.new(year, month, 21) - 1.month
      end_date = Date.new(year, month, 20)
      [start_date, end_date]
    end
end

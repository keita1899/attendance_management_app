class AttendanceSummaryService
  attr_reader :start_date, :end_date

  def self.calculate_target_month(start_date_param)
    start_date = start_date_param.present? ? Date.parse(start_date_param) : Time.zone.today
    start_date.beginning_of_month
  end

  def initialize(user, target_month)
    @user = user
    @start_date, @end_date = calculate_pay_period(target_month)
  end

  def total_monthly_working_weekdays
    weekday_attendances.count
  end

  def total_monthly_working_weekends
    weekend_attendances.count
  end

  def total_monthly_working_days
    attendances.count
  end

  def total_monthly_weekday_working_minutes
    calculate_total_minutes(weekday_attendances, :working_minutes)
  end

  def total_monthly_weekend_working_minutes
    calculate_total_minutes(weekend_attendances, :working_minutes)
  end

  def total_monthly_working_minutes
    total_monthly_weekday_working_minutes + total_monthly_weekend_working_minutes
  end

  def total_monthly_weekday_overtime_minutes
    calculate_total_minutes(weekday_attendances, :overtime_minutes)
  end

  def total_monthly_weekend_overtime_minutes
    calculate_total_minutes(weekend_attendances, :overtime_minutes)
  end

  def total_monthly_overtime_minutes
    total_monthly_weekday_overtime_minutes + total_monthly_weekend_overtime_minutes
  end

  def total_monthly_weekday_daily_wage
    calculate_total_wage(weekday_attendances, :daily_wage)
  end

  def total_monthly_weekend_daily_wage
    calculate_total_wage(weekend_attendances, :daily_wage)
  end

  def total_monthly_daily_wage
    total_monthly_weekday_daily_wage + total_monthly_weekend_daily_wage
  end

  def total_monthly_weekday_overtime_pay
    calculate_total_wage(weekday_attendances, :overtime_pay)
  end

  def total_monthly_weekend_overtime_pay
    calculate_total_wage(weekend_attendances, :overtime_pay)
  end

  def total_monthly_overtime_pay
    total_monthly_weekday_overtime_pay + total_monthly_weekend_overtime_pay
  end

  def total_monthly_transport_cost
    TRANSPORT_COST * total_monthly_working_days
  end

  def total_monthly_payment
    total_monthly_daily_wage + total_monthly_overtime_pay + total_monthly_transport_cost
  end

  def pay_period
    [@start_date, @end_date]
  end

  private

    def attendances
      @attendances ||= @user.attendances.
                         where(date: @start_date..@end_date).
                         where.not(clock_out_time: nil)
    end

    def weekday_attendances
      @weekday_attendances ||= attendances.where.not("extract(dow from date) in (?)", [0, 6])
    end

    def weekend_attendances
      @weekend_attendances ||= attendances.where("extract(dow from date) in (?)", [0, 6])
    end

    def calculate_pay_period(target_month)
      year = target_month.year
      month = target_month.month

      start_date = Date.new(year, month, 21) - 1.month
      end_date = Date.new(year, month, 20)
      [start_date, end_date]
    end

    def calculate_total_minutes(attendances, method)
      attendances.sum {|attendance| attendance.public_send(method) }
    end

    def calculate_total_wage(attendances, method)
      attendances.sum {|attendance| attendance.public_send(method) }
    end
end

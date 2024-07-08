class Attendance < ApplicationRecord
  belongs_to :user

  GUARANTEED_WAGE_MINUTES = 240
  OVERTIME_INTERVAL_MINUTES = 30

  def update_attendance_data
    update(
      working_minutes: calculate_working_minutes,
      overtime_minutes: calculate_overtime_minutes,
      total_working_minutes: calculate_total_working_minutes,
      hourly_wage: set_hourly_wage,
      daily_wage: calculate_daily_wage,
      overtime_pay: calculate_overtime_pay,
      allowance: set_allowance,
      transport_cost: TRANSPORT_COST,
      total_payment: calculate_daily_total_payment,
    )
  end

  def fetch_special_day
    @special_day ||= SpecialDay.for_date(date)
  end

  def special_day?
    fetch_special_day.present?
  end

  private

    def calculate_working_minutes
      total_working_minutes = calculate_total_working_minutes
      total_working_minutes - calculate_overtime_minutes
    end

    def calculate_overtime_minutes
      total_working_minutes = calculate_total_working_minutes
      [total_working_minutes - GUARANTEED_WAGE_MINUTES, 0].max
    end

    def calculate_total_working_minutes
      convert_seconds_to_minutes(clock_out_time - clock_in_time).to_i
    end

    def set_hourly_wage
      base_wage = weekend? ? user.wage.weekend_hourly_wage : user.wage.weekday_hourly_wage
      base_wage += fetch_special_day.wage_increment if special_day?
      base_wage
    end

    def weekend?
      [0, 6].include?(date.wday)
    end

    def calculate_daily_wage
      set_hourly_wage * convert_minutes_to_hour(GUARANTEED_WAGE_MINUTES)
    end

    def calculate_overtime_pay
      overtime_minutes = calculate_overtime_minutes
      half_hourly_wage = set_hourly_wage / 2
      (overtime_minutes >= OVERTIME_INTERVAL_MINUTES) ? (overtime_minutes / OVERTIME_INTERVAL_MINUTES) * half_hourly_wage : 0
    end

    def set_allowance
      special_day? ? fetch_special_day.allowance : allowance
    end

    def calculate_daily_total_payment
      calculate_daily_wage + calculate_overtime_pay + TRANSPORT_COST + allowance
    end

    def convert_minutes_to_hour(minutes)
      minutes / 60
    end

    def convert_seconds_to_minutes(seconds)
      seconds / 60
    end
end

module AttendanceSummaryCalculations
  def total_monthly_working_days
    @attendances.size
  end

  def total_monthly_weekday_working_minutes
    calculate_total_minutes(weekday_attendances)
  end

  def total_monthly_weekend_working_minutes
    calculate_total_minutes(weekend_attendances)
  end

  def total_monthly_special_day_working_minutes
    calculate_total_minutes(special_day_attendances)
  end

  def total_monthly_working_minutes
    total_monthly_weekday_working_minutes + total_monthly_weekend_working_minutes + total_monthly_special_day_working_minutes
  end

  def total_monthly_weekday_overtime_minutes
    calculate_total_overtime_minutes(weekday_attendances)
  end

  def total_monthly_weekend_overtime_minutes
    calculate_total_overtime_minutes(weekend_attendances)
  end

  def total_monthly_special_day_overtime_minutes
    calculate_total_overtime_minutes(special_day_attendances)
  end

  def total_monthly_overtime_minutes
    total_monthly_weekday_overtime_minutes + total_monthly_weekend_overtime_minutes + total_monthly_special_day_overtime_minutes
  end

  def total_monthly_weekday_daily_wage
    calculate_total_wage(weekday_attendances, :daily_wage)
  end

  def total_monthly_weekend_daily_wage
    calculate_total_wage(weekend_attendances, :daily_wage)
  end

  def total_monthly_special_day_daily_wage
    calculate_total_wage(special_day_attendances, :daily_wage)
  end

  def total_monthly_daily_wage
    total_monthly_weekday_daily_wage + total_monthly_weekend_daily_wage + total_monthly_special_day_daily_wage
  end

  def total_monthly_weekday_overtime_pay
    calculate_total_wage(weekday_attendances, :overtime_pay)
  end

  def total_monthly_weekend_overtime_pay
    calculate_total_wage(weekend_attendances, :overtime_pay)
  end

  def total_monthly_special_day_overtime_pay
    calculate_total_wage(special_day_attendances, :overtime_pay)
  end

  def total_monthly_overtime_pay
    total_monthly_weekday_overtime_pay + total_monthly_weekend_overtime_pay + total_monthly_special_day_overtime_pay
  end

  def total_monthly_special_day_allowance
    special_day_attendances.sum(&:allowance)
  end

  def total_monthly_transport_cost
    TRANSPORT_COST * total_monthly_working_days
  end

  def total_monthly_payment
    total_monthly_daily_wage + total_monthly_overtime_pay + total_monthly_special_day_allowance + total_monthly_transport_cost
  end

  private

    def calculate_total_minutes(attendances)
      attendances.sum(&:working_minutes)
    end

    def calculate_total_overtime_minutes(attendances)
      attendances.sum(&:overtime_minutes)
    end

    def calculate_total_wage(attendances, method)
      attendances.sum(&method)
    end
end

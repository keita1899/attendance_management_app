FactoryBot.define do
  factory :attendance do
    date { Time.zone.local(2024, 6, 10) }
    clock_in_time { date.change(hour: 10, min: 0) }
    clock_out_time { date.change(hour: 14, min: 0) }
    transient do
      weekend { false }
    end

    hourly_wage do |attendance|
      if attendance.weekend
        attendance.user.wage.weekend_hourly_wage
      else
        attendance.user.wage.weekday_hourly_wage
      end
    end
    association :user
  end

  factory :saturday_attendance, parent: :attendance do
    date { Time.zone.local(2024, 6, 15) }
    transient do
      weekend { true }
    end
  end

  factory :sunday_attendance, parent: :attendance do
    date { Time.zone.local(2024, 6, 16) }
    transient do
      weekend { true }
    end
  end
end

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

  trait :clock_out_1300 do
    clock_out_time { date.change(hour: 13, min: 0) }
  end

  trait :clock_out_1401 do
    clock_out_time { date.change(hour: 14, min: 1) }
  end

  trait :clock_out_1429 do
    clock_out_time { date.change(hour: 14, min: 29) }
  end

  trait :clock_out_1430 do
    clock_out_time { date.change(hour: 14, min: 30) }
  end

  trait :clock_out_1431 do
    clock_out_time { date.change(hour: 14, min: 31) }
  end

  trait :clock_out_1459 do
    clock_out_time { date.change(hour: 14, min: 59) }
  end

  trait :clock_out_1500 do
    clock_out_time { date.change(hour: 15, min: 0) }
  end
end

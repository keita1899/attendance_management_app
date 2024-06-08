FactoryBot.define do
  factory :wage do
    weekday_hourly_wage { 1000 }
    weekend_hourly_wage { 1100 }
    association :user
  end
end

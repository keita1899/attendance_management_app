FactoryBot.define do
  factory :wage do
    weekday_rate { 1000 }
    weekend_rate { 1100 }
    association :user
  end
end

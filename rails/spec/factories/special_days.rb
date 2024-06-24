FactoryBot.define do
  factory :special_day do
    start_date { Time.zone.local(2024, 8, 13) }
    end_date { Time.zone.local(2024, 8, 16) }
    description { "お盆" }
    wage_increment { 100 }
    allowance { 1500 }
  end
end

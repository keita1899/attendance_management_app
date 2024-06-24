FactoryBot.define do
  factory :special_day do
    sequence(:start_date) {|n| Time.zone.local(2024, 1, 1) + (n - 1) * 2.days }
    sequence(:end_date) {|n| Time.zone.local(2024, 1, 2) + (n - 1) * 2.days }
    sequence(:description) {|n| "Special Day #{n}" }
    wage_increment { 100 }
    allowance { 1500 }
  end
end

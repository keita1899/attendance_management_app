100.times do |n|
  user = User.create!(
    last_name: "山田",
    first_name: "太郎",
    last_name_kana: "ヤマダ",
    first_name_kana: "タロウ",
    email: "test#{n}@example.com",
    password: "password",
    password_confirmation: "password",
  )
  user.create_wage(
    weekday_hourly_wage: 1000,
    weekend_hourly_wage: 1100,
  )

  user.create_attendance(
    date: Time.zone.today,
    clock_in_time: Time.zone.now.beginning_of_day + 10.hours,
    clock_out_time: Time.zone.now.beginning_of_day + 14.hours,
    working_minutes: 240,
    overtime_minutes: 0,
    total_working_minutes: 240,
    hourly_wage: 1000,
    daily_wage: 4000,
    transport_cost: 320,
    allowance: 0,
    total_payment: 4320,
    special_day: false,
  )
end

Admin.create!(
  name: "admin",
  password: "password",
)

SpecialDay.create!(
  start_date: Time.zone.local(2024, 8, 13),
  end_date: Time.zone.local(2024, 8, 18),
  description: "お盆",
  wage_increment: 100,
  allowance: 1500,
)

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
end

Admin.create!(
  name: "admin",
  password: "password",
)

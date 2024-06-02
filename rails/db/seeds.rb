100.times do |n|
  User.create!(
    last_name: "山田",
    first_name: "太郎",
    last_name_kana: "ヤマダ",
    first_name_kana: "タロウ",
    email: "test#{n}@example.com",
    password: "password",
    password_confirmation: "password",
  )
end

Admin.create!(
  name: "admin",
  password: "password",
)

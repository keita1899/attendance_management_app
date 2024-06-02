FactoryBot.define do
  factory :user do
    last_name { "山田" }
    first_name { "太郎" }
    last_name_kana { "ヤマダ" }
    first_name_kana { "タロウ" }
    sequence(:email) {|n| "test#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "テストユーザー" }
    password { "password123" }
    password_confirmation { password }
  end
end

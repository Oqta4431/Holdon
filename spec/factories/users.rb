FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "テストユーザー" }
    password { "password123" }
    password_confirmation { password }

    trait :line_user do
      provider { "line" }
      uid { "U1234567890abcdef" }
    end
  end
end

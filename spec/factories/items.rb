FactoryBot.define do
  factory :item do
    association :user
    sequence(:name) { |n| "Item #{n}" }
    price { 1000 }
    url { nil }
    memo { nil }
  end
end

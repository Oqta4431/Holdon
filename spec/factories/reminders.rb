FactoryBot.define do
  factory :reminder do
    association :item
    remind_at { 1.hour.from_now }
    remind_interval { 300 }
    notified_at { nil }
  end
end

FactoryBot.define do
  factory :review do
    association :item
    satisfaction_score { 3 }
    comment { nil }
  end
end

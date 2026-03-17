FactoryBot.define do
  factory :category do
    association :user
    # sequence で連番にすることで同一ユーザー内の name 重複バリデーションをすり抜けない
    sequence(:name) { |n| "カテゴリ#{n}" }
  end
end

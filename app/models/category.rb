class Category < ApplicationRecord
  belongs_to :user
  # カテゴリーが削除されても紐づくItemは削除しない（category_idをNULLに更新）
  has_many :items, dependent: :nullify

  validates :name, presence: true, length: { maximum: 30 }, uniqueness: { scope: :user_id }
end

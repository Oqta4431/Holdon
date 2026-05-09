class Review < ApplicationRecord
  belongs_to :item

  validates :item_id, uniqueness: true
  validates :satisfaction_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, length: { maximum: 2_000 }, allow_blank: true
end

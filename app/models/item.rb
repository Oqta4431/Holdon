class Item < ApplicationRecord
  validates :name, presence: true, length: { maximum: 225 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :url, length: { maximum: 225 }, allow_blank: true
  validates :image, length: { maximum: 225 }, allow_blank: true
  validates :memo, length: { maximum: 65_535 }, allow_blank: true

  belongs_to :user

  has_one :judgement, dependent: :destroy
  has_one :reminder, dependent: :destroy
end

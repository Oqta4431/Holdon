class Item < ApplicationRecord
  has_one_attached :item_image

  validates :item_image,
            content_type: {
              in: %w[
                image/jpeg
                image/png
                image/webp
                image/heic
                image/heif
                image/heic-sequence
                image/heif-sequence
              ]
            },
            size: { less_than: 5.megabytes }
  validates :name, presence: true, length: { maximum: 225 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :url, length: { maximum: 225 }, allow_blank: true
  validates :image, length: { maximum: 225 }, allow_blank: true
  validates :memo, length: { maximum: 65_535 }, allow_blank: true

  belongs_to :user

  has_one :judgement, dependent: :destroy
  has_one :reminder, dependent: :destroy

  ## 判断対象の商品を取得
  scope :ready_for_judgement, -> {
    joins(:judgement, :reminder)
    .where(judgements: { purchase_status: Judgement.purchase_statuses[:considering] })
    .where("reminders.remind_at <= ?", Time.current)
  }
end

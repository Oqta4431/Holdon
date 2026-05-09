class Item < ApplicationRecord
  has_one_attached :item_image do |attachable|
    attachable.variant :thumb,
                        resize_to_fill: [ 80, 80 ],
                        format: :webp,
                        saver: { quality: 75, strip: true }

    attachable.variant :large,
                        resize_to_limit: [ 800, 800 ],
                        format: :webp,
                        saver: { quality: 82, strip: true }
  end

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
  # カテゴリーは任意（未分類の商品も登録できる）
  belongs_to :category, optional: true

  has_one :judgement, dependent: :destroy
  has_one :reminder, dependent: :destroy
  has_one :reason, dependent: :destroy
  has_one :review, dependent: :destroy

  ## 判断対象の商品を取得
  scope :ready_for_judgement, -> {
    joins(:judgement, :reminder)
    .where(judgements: { purchase_status: Judgement.purchase_statuses[:considering] })
    .where("reminders.remind_at <= ?", Time.current)
  }

  # 判断レビュー対象の絞り込み
  scope :ready_for_review, -> {
    ## last_week_start : 日曜日の00:00
    ## last_week_end   : 土曜日の23:59(日曜の00:00)
    today_jst = Time.current.in_time_zone("Tokyo")
    last_week_end = today_jst.beginning_of_day - today_jst.wday.days
    last_week_start = last_week_end - 7.days

    ## ① purchased か skipped の全件
    ## ② 日曜 00:00 ~ 土曜 23:59 の間
    ## ③ 購入判断がされている（異常系への対処、purchased, skipped だが decided_at: nil があり得るかもしれない）
    ## ④ left_outer_join の結果、reviews.id: nil

    includes(:judgement)
    .joins(:judgement)
    .left_outer_joins(:review)
    .where(judgements: { purchase_status: [ Judgement.purchase_statuses[:purchased], Judgement.purchase_statuses[:skipped] ] })
    .where("judgements.decided_at >= ?", last_week_start)
    .where("judgements.decided_at < ?", last_week_end)
    .where.not(judgements: { decided_at: nil })
    .where(reviews: { id: nil })
  }
end

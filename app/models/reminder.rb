class Reminder < ApplicationRecord
  # リマインド間隔の上下限（秒単位）
  # 下限：1分 / 上限：60日 / デフォルト：24時間
  REMIND_INTERVAL_MIN = 60          # 1分
  REMIND_INTERVAL_MAX = 5_184_000   # 60日
  DEFAULT_REMIND_INTERVAL = 86_400  # 24時間

  validates :remind_at, presence: true
  validates :remind_interval,
            numericality: {
              greater_than_or_equal_to: REMIND_INTERVAL_MIN,
              less_than_or_equal_to: REMIND_INTERVAL_MAX
            }

  belongs_to :item

  # 再検討履歴：同じリマインダーに対して複数回の再検討が発生しうるため has_many
  has_many :past_reminders, dependent: :destroy
end

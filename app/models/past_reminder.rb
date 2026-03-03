class PastReminder < ApplicationRecord
  validates :past_remind_at, presence: true

  belongs_to :reminder
end

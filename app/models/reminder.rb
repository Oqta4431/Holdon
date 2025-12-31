class Reminder < ApplicationRecord
  validates :remind_at, presence: true
  validates :remind_interval, numericality: { greater_than: 0 }, allow_nil: true

  belongs_to :item
end

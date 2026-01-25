class Judgement < ApplicationRecord
  validates :purchase_status, presence: true

  belongs_to :item

  enum purchase_status: { considering: 0, purchased: 1, skipped: 2 }
end

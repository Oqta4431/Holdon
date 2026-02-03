class Reason < ApplicationRecord
  belongs_to :item

  validates :purchase_reason, length: { maximum: 2000 }, allow_blank: true
  validates :skip_reason, length: { maximum: 2000 }, allow_blank: true
  validates :item_id, uniqueness: true
end

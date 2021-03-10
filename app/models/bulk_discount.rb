class BulkDiscount < ApplicationRecord
  validates_presence_of :merchant_id,
                        :percentage_discount,
                        :threshold
  validates_numericality_of :percentage_discount, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 100

  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
end
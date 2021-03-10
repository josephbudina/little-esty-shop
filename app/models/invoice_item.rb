class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  has_many :bulk_discounts, through: :item
  enum status: {pending: 0, packaged: 1, shipped: 2}

  def change_status(status)
    self.update(status: status.downcase)
  end

  def self.calculate_revenue
   sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def applied
    if invoice.get_discount.ids.include?(id)
      discount_id = invoice.get_discount.find(id).discount_id
      discount = BulkDiscount.find(discount_id)
    else
      nil
    end
  end

  def applied_discount
    if applied != nil
      "discount_link"
    else
      "no_discount"
    end
  end
end
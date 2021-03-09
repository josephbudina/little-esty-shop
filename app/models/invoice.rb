class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  enum status: {"in progress" => 0, completed: 1, cancelled: 2}

  def total_revenue
    invoice_items.calculate_revenue
  end

  def self.not_shipped
    joins(:invoice_items)
    .where("invoice_items.status = 0 OR invoice_items.status = 1")
    .distinct
    .order(created_at: :asc)
  end

  def date_format
    created_at.strftime("%A, %B %d, %Y")
  end

  def status_format
    status.titleize
  end

  def apply_discount
    invoice_items.joins(:bulk_discounts)
    .where('invoice_items.quantity >= bulk_discounts.threshold')
    .select('invoice_items.*, (bulk_discounts.percentage_discount * invoice_items.quantity * invoice_items.unit_price) as discount_amount')
    .order('bulk_discounts.percentage_discount')
  end

  def find_discount(id)
    if apply_discount.where(id: id).empty?
      0
    else
      discount = apply_discount
      .where(id: id)
      .first
      .discount_amount
      (discount / 100)
    end
  end

  def discount_revenue
    discount = invoice_items.ids.sum do |id|
    find_discount(id)
    end
    (total_revenue - discount)
  end
end
class InvoiceItem < ApplicationRecord
  belongs_to :item
  has_one :merchant, through: :item
  has_many :bulk_discounts, through: :merchant
  belongs_to :invoice
  has_many :transactions, through: :invoice


  validates :quantity, presence: true, numericality: {only_integer: true}
  validates :unit_price, presence: true, numericality: {only_integer: true}


  enum status: { "pending" => 0, :packaged => 1, "shipped" =>2 }

  def self.revenue
    InvoiceItem.joins(invoice: :transactions).where(transactions: {result: 0})
    .sum("invoice_items.quantity * invoice_items.unit_price")
  end

  def revenue
    quantity * unit_price
  end

  def discount_available
    bulk_discounts.where("bulk_discounts.threshold <= ?", quantity).order(percent_discount: :desc).first
  end

  def discounted_revenue
    if discount_available == nil
      revenue
    else
      revenue - (revenue * discount_available.percentage)
    end
  end
end

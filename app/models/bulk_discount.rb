class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  validates :percent_discount, presence: true, numericality: {only_integer: true, greater_than: 1, less_than: 100}
  validates :threshold, presence: true, numericality: {only_integer: true, greater_than: 1}

  def format_discount
    percent_discount.to_s+ "%"
  end

  def percentage
    percent_discount/100.0
  end
end

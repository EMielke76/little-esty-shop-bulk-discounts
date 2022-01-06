class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: {only_integer: true}

  def self.invoice_finder(merchant_id)
    Invoice.joins(:invoice_items => :item).where(:items => {:merchant_id => merchant_id})
  end

end
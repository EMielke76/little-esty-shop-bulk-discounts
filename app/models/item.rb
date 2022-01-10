class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices

  enum status: [:Disabled, :Enabled]

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: {only_integer: true}


  def self.invoice_finder(merchant_id)
    Invoice.joins(:invoice_items => :item).where(:items => {:merchant_id => merchant_id})
  end

  def self.enabled_items
    Item.all.where(status: 1)
  end

  def self.disabled_items
    Item.all.where(status: 0)
  end

  def potential_revenue
    invoice_items.potential_revenue
  end
end

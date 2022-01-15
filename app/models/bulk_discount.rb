class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items

  validates :percent_discount, presence: true, numericality: {only_integer: true, greater_than: 1, less_than: 100}
  validates :threshold, presence: true, numericality: {only_integer: true, greater_than: 1}
end

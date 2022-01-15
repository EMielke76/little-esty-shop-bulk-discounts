require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many(:items).through(:merchant) }
    it { should have_many(:invoice_items).through(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:percent_discount)}
    it { should validate_numericality_of(:percent_discount), greater_than: 1, less_than: 100}
    it { should validate_presence_of(:threshold)}
    it { should validate_numericality_of(:threshold), greater_than: 1}
  end
end

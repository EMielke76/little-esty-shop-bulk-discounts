require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:items).through(:merchant) }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:percent_discount)}
    it { should validate_numericality_of(:percent_discount), greater_than: 1, less_than: 100}
    it { should validate_presence_of(:threshold)}
    it { should validate_numericality_of(:threshold), greater_than: 1}
  end

  describe '#format_discount' do
    it 'presents a discount in a human-readable manor' do
      discount_1 = create(:bulk_discount)
      discount_2 = create(:bulk_discount, percent_discount: 35)

      expect(discount_1.format_discount).to eq("20%")
      expect(discount_2.format_discount).to eq("35%")
    end
  end

  describe '#precentage' do
    it 'converts a discount into a float' do
      discount_1 = create(:bulk_discount)
      discount_2 = create(:bulk_discount, percent_discount: 35)

      expect(discount_1.percentage).to eq(0.20)
      expect(discount_2.percentage).to eq(0.35)
    end
  end
end

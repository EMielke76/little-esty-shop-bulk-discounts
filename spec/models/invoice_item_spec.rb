require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do

  describe 'relationships' do
    it { should belong_to(:item) }
    it { should have_one(:merchant).through(:item)}
    it { should have_many(:bulk_discounts).through(:merchant)}
    it { should belong_to(:invoice) }
    it { should have_many(:transactions).through(:invoice)}
  end

  describe 'enums validation' do
    it {should define_enum_for(:status).with([:pending, :packaged, :shipped])}
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity)}
    it { should validate_numericality_of(:quantity)}
    it { should validate_presence_of(:unit_price)}
    it { should validate_numericality_of(:unit_price)}
  end

  describe 'class methods' do

    describe '#revenue' do
      it 'can calculate total revenue of an invoice_item with a successful transaction' do
        merchant_1 = create(:merchant)
        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)
        transaction = create(:transaction, invoice: invoice_1, result: 0)

        expect(invoice_item_1.revenue).to eq(150000)
      end

      it 'returns nothting when a transaction was unsuccessful' do
        merchant_1 = create(:merchant)
        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)
        transaction = create(:transaction, invoice: invoice_1, result: 1)

        expect(invoice_item_1.revenue).to eq(0)
      end
    end

    describe '::revenue' do
      it "multiplies unit_price and quantity for a collection of invoice_items and sums them only if they are associated with an invoice that has at least 1 successful transaction" do
        invoice_1 = create(:invoice)
        invoice_2 = create(:invoice)
        invoice_item_1 = create(:invoice_item, quantity: 3, unit_price: 1000, invoice: invoice_1)
        invoice_item_2 = create(:invoice_item, quantity: 5, unit_price: 1000, invoice: invoice_1)
        invoice_item_3 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice_2)
        invoice_items = InvoiceItem.where(id:[invoice_item_1.id, invoice_item_2.id, invoice_item_3.id])

        # these invoice_items should not be included in any potential revenue
        invoice_3 = create(:invoice)
        invoice_item_4 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice_3)
        transaction = create(:transaction, result: 0, invoice: invoice_3)

        # test for no transactions
        expect(invoice_items.revenue).to eq(0)

        # test for no successful transactions.
        transaction_1 = create(:transaction, result: 1, invoice: invoice_1)
        expect(invoice_items.revenue).to eq(0)

        # test for successful transactions
        transaction_2 = create(:transaction, result: 0, invoice: invoice_1)
        expect(invoice_items.revenue).to eq(8000)

        # test for multiple invoices with successful transactions
        transaction_3 = create(:transaction, result: 0, invoice: invoice_2)
        expect(invoice_items.revenue).to eq(9000)
      end
    end

    describe "#discount_available" do
      it 'finds a discount' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)

        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1)
        bulk_discount_2 = create(:bulk_discount, merchant: merchant_1, threshold: 15, percent_discount: 25)

        expect(invoice_item_1.discount_available).to eq(bulk_discount_1)
      end

      it 'finds the highest applicable discount' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)

        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1)
        bulk_discount_2 = create(:bulk_discount, merchant: merchant_1, percent_discount: 25)

        expect(invoice_item_1.discount_available).to eq(bulk_discount_2)
      end
    end

    describe "#discounted_revenue" do
      it 'can calucate revenue with a discount applied' do
        merchant_1 = create(:merchant)
        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)
        transaction = create(:transaction, invoice: invoice_1, result: 0)

        expect(invoice_item_1.discounted_revenue).to eq(120000)
      end

      it 'calculates revenue with the highest discount available applied' do
        merchant_1 = create(:merchant)
        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1, percent_discount: 10)
        bulk_discount_2 = create(:bulk_discount, merchant: merchant_1, percent_discount: 50)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)
        transaction = create(:transaction, invoice: invoice_1, result: 0)

        expect(invoice_item_1.discounted_revenue).to eq(75000.0)
      end

      it 'calculates revenue with the highest percentage discount available applied if multiple thresholds are met' do
        merchant_1 = create(:merchant)
        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1, threshold: 8, percent_discount: 50)
        bulk_discount_2 = create(:bulk_discount, merchant: merchant_1, percent_discount: 20)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 10, unit_price: 15000)
        transaction = create(:transaction, invoice: invoice_1, result: 0)

        expect(invoice_item_1.discounted_revenue).to eq(75000.0)
      end

      it 'still calculates revenue if no discount applies' do
        merchant_1 = create(:merchant)
        bulk_discount_1 = create(:bulk_discount, merchant: merchant_1)
        item_1 = create(:item, merchant: merchant_1)
        invoice_1 = create(:invoice)
        invoice_item_1 = create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 5, unit_price: 15000)
        transaction = create(:transaction, invoice: invoice_1, result: 0)

        expect(invoice_item_1.discounted_revenue).to eq(75000)
      end
    end
  end
end

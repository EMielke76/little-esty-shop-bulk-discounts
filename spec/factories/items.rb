FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "Default Item Name #{n}" }
    description { "Default Description" }
    sequence(:unit_price) { |n| 10000 + (n * 1000) }
    merchant

    factory :item_with_invoices do

      transient do
        invoice_count {2}
        invoice {create(:invoice)}
        invoice_item_unit_price {15000}
        invoice_item_status {0}
      end

      after(:create) do |item, evaluator|
        evaluator.invoice_count.times do
          invoice_item = create(:invoice_item,
          invoice: evaluator.invoice,
          item: item,
          unit_price: evaluator.invoice_item_unit_price,
          status: evaluator.invoice_item_status)
        end
        item.reload
      end
    end
  end
end
FactoryBot.define do
  factory :bulk_discount do
    percent_discount { 20 }
    threshold { 10 }
    merchant
  end
end

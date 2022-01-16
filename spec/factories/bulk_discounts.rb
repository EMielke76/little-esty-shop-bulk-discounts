FactoryBot.define do
  factory :bulk_discount do
    percent_discount { 10 }
    threshold { 15 }
    merchant
  end
end

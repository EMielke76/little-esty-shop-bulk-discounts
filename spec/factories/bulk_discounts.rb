FactoryBot.define do
  factory :bulk_discount do
    percent_discount { 1 }
    threshold { 1 }
    merchant
  end
end

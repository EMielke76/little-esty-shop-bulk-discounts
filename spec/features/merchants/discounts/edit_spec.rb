require 'rails_helper'

RSpec.describe 'merchant discount edit page' do

  it 'displays a form to edit the discount' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount, merchant: merchant)

    visit "/merchants/#{merchant.id}/discounts/#{bd_1.id}/edit"

    within("#update_item") do
      expect(page).to have_content("Edit Bob Barker's Discount ##{bd_1.id}")
      expect(page).to have_field("Percent Discount")
      expect(page).to have_field("Threshold")
    end
  end

  it 'prepopulates the fields with data from the discount' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount, merchant: merchant)

    visit "/merchants/#{merchant.id}/discounts/#{bd_1.id}/edit"

    within("#update_item") do
      expect(page).to have_field(:percent_discount, with: 20)
      expect(page).to have_field(:threshold, with: 10)
    end
  end

  it 'redirects back to the discount show page and changes are reflected' do
  end
end

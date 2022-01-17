require 'rails_helper'

RSpec.describe 'Merchant Discounts index page' do

  it 'displays all bulk discounts including their discount and threshold' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount)
    bd_2 = create(:bulk_discount, threshold: 5, percent_discount: 10)
    bd_3 = create(:bulk_discount, threshold: 15, percent_discount: 25)

    visit "/merchant/#{merchant.id}/discounts"

    within("discount_#{bd_1.id}") do
      expect(page).to have_content("Percent Discount: 20%")
      expect(page).to have_content("Threshold: 10 items")
    end

    within("discount_#{bd_2.id}") do
      expect(page).to have_content("Percent Discount: 10%")
      expect(page).to have_content("Threshold: 5 items")
    end

    within("discount_#{bd_3.id}") do
      expect(page).to have_content("Percent Discount: 25%")
      expect(page).to have_content("Threshold: 15 items")
    end
  end

  xit 'displays a link to each discounts show page' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount)
    bd_2 = create(:bulk_discount, threshold: 5, percent_discount: 10)

    visit "/merchant/#{merchant.id}/discounts"

    within("discount_#{bd_1.id}") do
      expect(page).to have_link("Discount #{bd_1.id}'s Information")
      click_link "Discount #{bd_1.id}'s Information"
      expect(current_path).to eq("merchants/#{merchant.id}/discounts/#{bd_1.id}")
    end

    visit "/merchant/#{merchant.id}/discounts"

    within("discount_#{bd_2.id}") do
      expect(page).to have_link("Discount #{bd_2.id}'s Information")
      click_link "Discount #{bd_2.id}'s Information"
      expect(current_path).to eq("merchants/#{merchant.id}/discounts/#{bd_2.id}")
    end
  end
end

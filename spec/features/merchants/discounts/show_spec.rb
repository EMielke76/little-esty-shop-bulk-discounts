require 'rails_helper'

RSpec.describe 'merchant bulk discount show page' do

  it 'displays the discounts quantity threshold and percent discount' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount, merchant: merchant)

    visit "/merchants/#{merchant.id}/discounts/#{bd_1.id}"

    expect(page).to have_content("Bob Barker's Discount #{bd_1.id}")
    expect(page).to have_content("Percent Discount: 20%")
    expect(page).to have_content("Threshold: 10 items")
  end

  describe 'a link to edit page' do
    it 'displays a link to edit the discount' do
      merchant = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant)

      visit "/merchants/#{merchant.id}/discounts/#{bd_1.id}"

      exepct(page).to have_content("Edit Discount #{bd_1.id}")
    end

    it 'links to the edit page' do
      merchant = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant)

      visit "/merchants/#{merchant.id}/discounts/#{bd_1.id}"

      exepct(page).to have_content("Edit Discount #{bd_1.id}")
      click_on("Edit Discount #{bd_1.id}")
      expect(current_path).to eq("/merchants/#{merchant.id}/discounts/#{bd_1.id}/edit")
    end 
  end
end

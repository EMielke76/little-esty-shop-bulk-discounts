require 'rails_helper'

RSpec.describe 'merchant discount edit page' do

  it 'displays a form to edit the discount' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount, merchant: merchant)

    visit "/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit"

    expect(page).to have_content("Edit Bob Barker's Discount ##{bd_1.id}")

    within("#update_discount") do
      expect(page).to have_field(:percent_discount)
      expect(page).to have_field(:threshold)
    end
  end

  it 'prepopulates the fields with data from the discount' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount, merchant: merchant)

    visit "/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit"

    within("#update_discount") do
      expect(page).to have_field(:percent_discount, with: 20)
      expect(page).to have_field(:threshold, with: 10)
    end
  end

  it 'redirects back to the discount show page and changes are reflected' do
    merchant = create(:merchant, name: "Bob Barker")
    bd_1 = create(:bulk_discount, merchant: merchant)

    visit "/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit"

    within("#update_discount") do
      fill_in(:percent_discount, with: 10)
      fill_in(:threshold, with: 20)
      click_on "Save"
    end
    expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}")
    visit "/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}"

    expect(page).to have_content("Bob Barker's Discount #{bd_1.id}")
    expect(page).to have_content("Percent Discount: 10%")
    expect(page).to have_content("Threshold: 20 items")
  end

  describe 'sad path testing' do
    it 'displays error messages if incorrect data is entered' do
      merchant = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant)

      visit "/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit"

      within("#update_discount") do
        fill_in(:percent_discount, with: -10)
        fill_in(:threshold, with: -10)
        click_on "Save"
      end
      expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit")

      within("#errors") do
        expect(page).to have_content("Error: Percent discount must be greater than 1")
        expect(page).to have_content("Error: Threshold must be greater than 1")
      end

      within("#update_discount") do
        fill_in(:percent_discount, with: 101)
        fill_in(:threshold, with: 10)
        click_on "Save"
      end

      within("#errors") do
        expect(page).to have_content("Error: Percent discount must be less than 100")
      end
    end

    it 'displays error messages if incorrect data type entered' do
      merchant = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant)

      visit "/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit"

      within("#update_discount") do
        fill_in(:percent_discount, with: "Batman")
        fill_in(:threshold, with: "Robin")
        click_on "Save"
      end
      expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts/#{bd_1.id}/edit")

      within("#errors") do
        expect(page).to have_content("Error: Percent discount is not a number")
        expect(page).to have_content("Error: Threshold is not a number")
      end
    end
  end
end

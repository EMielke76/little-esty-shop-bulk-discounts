require 'rails_helper'

RSpec.describe "merchant discount creation" do

  it 'displays a from to create a discount' do
    merchant = create(:merchant, name: "Bob Barker")

    visit new_merchant_bulk_discount_path(merchant)

    expect(page).to have_field("Discount Percentage")
    expect(page).to have_field("Threshold")
  end

  it 'displays an error when not filled in' do
    merchant = create(:merchant, name: "Bob Barker")

    visit new_merchant_bulk_discount_path(merchant)

    within("#create_discount") do
      click_on "Save"
    end

    expect(current_path).to eq(new_merchant_bulk_discount_path(merchant))

    within("#errors") do
      expect(page).to have_content("Error: Percent discount can't be blank")
      expect(page).to have_content("Error: Percent discount is not a number")
      expect(page).to have_content("Error: Threshold can't be blank")
      expect(page).to have_content("Error: Threshold is not a number")
    end
  end

  it 'displays an error when filled in with the incorrect datatype' do
    merchant = create(:merchant, name: "Bob Barker")

    visit new_merchant_bulk_discount_path(merchant)

    within("#create_discount") do
      fill_in("Discount Percentage", with: "Batman")
      fill_in("Threshold", with: "Robin")
      click_on "Save"
    end

    within("#errors") do
      expect(page).to have_content("Error: Percent discount is not a number")
      expect(page).to have_content("Error: Threshold is not a number")
    end
  end

  it 'displays an error when a number thats too large or too small is entered' do
    merchant = create(:merchant, name: "Bob Barker")

    visit new_merchant_bulk_discount_path(merchant)

    within("#create_discount") do
      fill_in("Discount Percentage", with: 101)
      fill_in("Threshold", with: -1)
      click_on "Save"
    end

    expect(current_path).to eq(new_merchant_bulk_discount_path(merchant))

    within("#errors") do
      expect(page).to have_content("Error: Percent discount must be less than 100")
      expect(page).to have_content("Error: Threshold must be greater than 1")
    end

    visit new_merchant_bulk_discount_path(merchant)

    within("#create_discount") do
      fill_in("Discount Percentage", with: -1)
      fill_in("Threshold", with: 5)
      click_on "Save"
    end

    expect(current_path).to eq(new_merchant_bulk_discount_path(merchant))

    within("#errors") do
      expect(page).to have_content("Error: Percent discount must be greater than 1")
    end
  end


  it 'redirects back to discount index upon correct completion' do
    merchant = create(:merchant, name: "Bob Barker")

    visit new_merchant_bulk_discount_path(merchant)

    expect(page).to_not have_content("Percent Discount: 10%")
    expect(page).to_not have_content("Threshold: 10 items")

    visit new_merchant_bulk_discount_path(merchant)

    within("#create_discount") do
      fill_in("Discount Percentage", with: 10)
      fill_in("Threshold", with: 10)
      click_on "Save"
    end

    expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts")
    expect(page).to have_content("Percent Discount: 10%")
    expect(page).to have_content("Threshold: 10 items")
  end
end

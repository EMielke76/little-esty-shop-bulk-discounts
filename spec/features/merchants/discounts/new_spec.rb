require 'rails_helper'

RSpec.describe "merchant discount creation" do

  it 'displays a from to create a discount' do
    merchant = create(:merchant, name: "Bob Barker")

    visit "/merchants/#{merchant.id}/discounts/new"

    expect(page).to have_field("Discount Percentage")
    expect(page).to have_field("Threshold")
  end

  it 'displays an error when not filled in' do
    merchant = create(:merchant, name: "Bob Barker")

    visit "/merchants/#{merchant.id}/discounts/new"

    within("#create_discount") do
      click_on "Save"
    end
    
    expect(current_path).to eq("/merchants/#{merchant.id}/discounts/new")

    within("#errors") do
      expect(page).to have_content("Error: Percent discount can't be blank")
      expect(page).to have_content("Error: Percent discount is not a number")
      expect(page).to have_content("Error: Threshold can't be blank")
      expect(page).to have_content("Error: Threshold is not a number")
    end
  end

  xit 'displays an error when filled in with the incorrect datatype' do
    merchant = create(:merchant, name: "Bob Barker")

    visit "/merchants/#{merchant.id}/discounts/new"

    within("#create_discount") do
      fill_in(:percent_discount, with: "Batman")
      fill_in(:threshold, with: "Robin")
      click_on "Save"
    end

    expect(current_path).to eq("/merchants/#{merchant.id}/discounts/new")
    expect(page).to have_content("Error: Percent Discount must be a number, Threshold must be a number")
  end

  xit 'displays an error when a number thats too large or too small is entered' do
    merchant = create(:merchant, name: "Bob Barker")

    visit "/merchants/#{merchant.id}/discounts/new"

    within("#create_discount") do
      fill_in(:percent_discount, with: 101)
      fill_in(:threshold, with: -1)
      click_on "Save"
    end

    expect(current_path).to eq("/merchants/#{merchant.id}/discounts/new")
    expect(page).to have_content("Error: Percent Discount must under 100, Threshold must over 1")
  end


  xit 'redirects back to discount index upon complettion' do
  end
end

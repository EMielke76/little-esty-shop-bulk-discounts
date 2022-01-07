require 'rails_helper'

RSpec.describe 'merchant dashboard' do
  it "When I visit a merchant dashboard I see the name of my merchant" do
    merchant = create(:merchant, name: 'Bob')
    visit "/merchants/#{merchant.id}/dashboard"
    expect(page).to have_content('Bob')
  end

  it 'has a link to merchant invoices index' do
    merchant = create(:merchant_with_invoices, invoice_count: 3)
    visit "/merchants/#{merchant.id}/dashboard"
    click_link "Invoices"
    expect(current_path).to eq("/merchants/#{merchant.id}/invoices")
  end

  it 'has a link to merchant items index' do
    merchant = create(:merchant_with_items, item_count: 3)
    visit "/merchants/#{merchant.id}/dashboard"
    click_link "Items"
    expect(current_path).to eq("/merchants/#{merchant.id}/items")
  end

  it "has the names of the top 5 customers with largest number of completed transactions" do
    merchant = create(:merchant)

    customer_1 = create(:customer_with_transactions, merchant: merchant, transaction_result: 0, transaction_count: 6, first_name: 'Bob')
    customer_2 = create(:customer_with_transactions, merchant: merchant, transaction_result: 0, transaction_count: 3, first_name: 'John')
    customer_3 = create(:customer_with_transactions, merchant: merchant, transaction_result: 0, transaction_count: 8, first_name: 'Abe')
    customer_4 = create(:customer_with_transactions, merchant: merchant, transaction_result: 0, transaction_count: 1, first_name: 'Zach')
    customer_5 = create(:customer_with_transactions, merchant: merchant, transaction_result: 0, transaction_count: 4, first_name: 'Charlie')

    visit "/merchants/#{merchant.id}/dashboard"

    within 'div.top_customers' do
      expect('Abe').to appear_before('Bob')
      expect('Bob').to appear_before('Charlie')
      expect('Charlie').to appear_before('John')
      expect('John').to appear_before('Zach')
    end
  end

  it "has a section called 'Items ready to ship'" do
    merchant = create(:merchant)
    visit "/merchants/#{merchant.id}/dashboard"
    within "div.items_ready_to_ship" do
      expect(page).to have_content("Items Ready to Ship")
    end
  end

  it "items ready to ship section shows all items that have been ordered and have not yet been shipped" do
    merchant = create(:merchant)
    item_1 = create(:item_with_invoices, merchant: merchant, invoice_item_status: 0, name: "item_1")
    item_2 = create(:item_with_invoices, merchant: merchant, invoice_item_status: 1, name: "item_2")
    item_3 = create(:item_with_invoices, merchant: merchant, invoice_item_status: 1, name: "item_3")
    item_4 = create(:item_with_invoices, merchant: merchant, invoice_item_status: 2, name: "item_4")
    visit "/merchants/#{merchant.id}/dashboard"

    within "div.items_ready_to_ship" do
      expect(page).to have_content("item_1")
      expect(page).to have_content("item_2")
      expect(page).to have_content("item_3")
      expect(page).to_not have_content("item_4")
    end
  end

  it "items ready to ship section shows invoice id next to item, and this is a link to the merchant invoice show page" do
    merchant = create(:merchant)
    item_1 = create(:item_with_invoices, merchant: merchant, invoice_item_status: 0, invoice_count: 1)
    item_2 = create(:item_with_invoices, merchant: merchant, invoice_item_status: 1, invoice_count: 2)
    invoice_1 = item_1.invoices.first
    invoice_2 = item_2.invoices.first
    invoice_3 = item_2.invoices.last


    visit "/merchants/#{merchant.id}/dashboard"
    within "div.item_#{item_1.id}" do
      click_link "Invoice ID: #{invoice_1.id}"
      expect(current_path).to eq("/merchants/#{merchant.id}/invoices/#{invoice_1.id}")
    end

    visit "/merchants/#{merchant.id}/dashboard"
    within "div.item_#{item_2.id}" do
      click_link "Invoice ID: #{invoice_2.id}"
      expect(current_path).to eq("/merchants/#{merchant.id}/invoices/#{invoice_2.id}")
    end

    visit "/merchants/#{merchant.id}/dashboard"
    within "div.item_#{item_2.id}" do
      click_link "Invoice ID: #{invoice_3.id}"
      expect(current_path).to eq("/merchants/#{merchant.id}/invoices/#{invoice_3.id}")
    end

  end
end

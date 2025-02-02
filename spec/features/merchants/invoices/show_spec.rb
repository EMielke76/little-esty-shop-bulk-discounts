require 'rails_helper'

RSpec.describe 'merchants invoice show page' do

  it 'displays all information related to that invoice' do
    merchant1 = create(:merchant, name: "Bob Barker")
    customer_1 = create(:customer, first_name: "Eric", last_name: "Mielke")
    invoice1 = create(:invoice, customer: customer_1)
    item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], name: 'Toy', invoice_item_unit_price: 15000)

    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    expect(page).to have_content("#{invoice1.id}'s Information")
    expect(page).to have_content("Merchant: Bob Barker")
    expect(page).to have_content("Status: in progress")
    expect(page).to have_content("Created On: #{invoice1.created_at.strftime("%A, %B %d, %Y")}")
    expect(page).to have_content("Customer: Eric Mielke")
  end

  it 'displays the invoiced item name' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], name: 'Toy')

    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    within("#invoice_#{item.id}") do
      expect(page).to have_content('Item: Toy')
    end
  end

  it 'displays the quantity of the item ordered' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], name: 'Toy')

    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    within("#invoice_#{item.id}") do
      expect(page).to have_content("Quantity Ordered: 8")
    end
  end

  it 'displays the price the item sold for' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], name: 'Toy', invoice_item_unit_price: 15000)

    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    within("#invoice_#{item.id}") do
      expect(page).to have_content("Unit Price: $150.00")
    end
  end

  it 'displays the invoice item status' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_status: 2)

    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    within("#status-#{item.id}") do
      expect(page).to have_field(:status, with: "shipped")
    end
  end

  it 'does not display any other merchants items information' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, name: 'Toy', merchant: merchant1, invoices: [invoice1])
    item2 = create(:item_with_invoices, name: 'Car', merchant: merchant1, invoices: [invoice1])
    item3 = create(:item_with_invoices, invoices: [invoice1])

    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    expect(page).to have_content(item.name)
    expect(page).to have_content(item2.name)
    expect(page).to_not have_content(item3.name)
  end

  it 'displays the total revenue that will be generated from the invoice' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, name: 'Toy', merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 150000)
    item2 = create(:item_with_invoices, name: 'Car', merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 200000)
    transaction = create(:transaction, invoice: invoice1, result: 0)


    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    within("#financial_reports") do
      expect(page).to have_content("Total Revenue")
      expect(page).to have_content("$28,000.00")
    end
  end

  it 'displays an invoices status as a select form' do
    merchant1 = create(:merchant, name: "Bob Barker")
    invoice1 = create(:invoice)
    item = create(:item_with_invoices, invoice_count: 1, name: 'Toy', merchant: merchant1, invoices: [invoice1])
    visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

    within("#status-#{item.id}") do
      expect(page).to have_field(:status, with: "pending")
      select 'packaged', from: :status
      click_on "Update Item Status"
      expect(current_path).to eq("/merchants/#{merchant1.id}/invoices/#{invoice1.id}")
      expect(page).to have_field(:status, with: "packaged")
      select 'shipped', from: :status
      click_on "Update Item Status"
      expect(current_path).to eq("/merchants/#{merchant1.id}/invoices/#{invoice1.id}")
      expect(page).to have_field(:status, with: "shipped")
    end
  end

  describe 'total and discounted revenue' do
    it 'displays the total revenue the merchant made from the invoice, not including discounts' do
      merchant1 = create(:merchant, name: "Bob Barker")
      invoice1 = create(:invoice)
      item = create(:item_with_invoices, name: 'Toy', merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 150000)
      item2 = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_quantity: 10, invoice_item_unit_price: 200000)
      transaction = create(:transaction, invoice: invoice1, result: 0)


      visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

      within("#financial_reports") do
        expect(page).to have_content("Total Revenue")
        expect(page).to have_content("$32,000.00")
      end
    end

    it 'displays the total revenue the merchant made from the invoice, including discounts' do
      merchant1 = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant1)
      invoice1 = create(:invoice)
      item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 150000)
      item2 = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_quantity: 10, invoice_item_unit_price: 200000)
      transaction = create(:transaction, invoice: invoice1, result: 0)


      visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

      within("#financial_reports") do
        expect(page).to have_content("Total Revenue")
        expect(page).to have_content("$32,000.00")
        expect(page).to have_content("Total Revenue With Discounts (if any)")
        expect(page).to have_content("$28,000.00")
      end
    end

    it 'displays the sum total if there are no applicable discounts' do
      merchant1 = create(:merchant, name: "Bob Barker")
      invoice1 = create(:invoice)
      item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 150000)
      item2 = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_quantity: 10, invoice_item_unit_price: 200000)
      transaction = create(:transaction, invoice: invoice1, result: 0)


      visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

      within("#financial_reports") do
        expect(page).to have_content("Total Revenue")
        expect(page).to have_content("$32,000.00")
        expect(page).to have_content("Total Revenue With Discounts (if any)")
        expect(page).to have_content("$32,000.00")
      end
    end

    it 'displays a link to a discounts show page if applicable' do
      merchant1 = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant1)
      invoice1 = create(:invoice)
      item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 150000)
      item2 = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_quantity: 10, invoice_item_unit_price: 200000)
      transaction = create(:transaction, invoice: invoice1, result: 0)


      visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

      within("#invoice_#{item2.id}") do
        expect(page).to have_content("Discount Applied!")
        expect(page).to have_link("See Discount #{bd_1.id}'s Info")
      end

      within("#invoice_#{item.id}") do
        expect(page).to_not have_content("Discount Applied!")
        expect(page).to_not have_link("See Discount #{bd_1.id}'s Info")
      end
    end

    it 'links to discounts show page if applicable' do
      merchant1 = create(:merchant, name: "Bob Barker")
      bd_1 = create(:bulk_discount, merchant: merchant1)
      invoice1 = create(:invoice)
      item = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_unit_price: 150000)
      item2 = create(:item_with_invoices, merchant: merchant1, invoices: [invoice1], invoice_item_quantity: 10, invoice_item_unit_price: 200000)
      transaction = create(:transaction, invoice: invoice1, result: 0)


      visit "/merchants/#{merchant1.id}/invoices/#{invoice1.id}"

      within("#invoice_#{item2.id}") do
        expect(page).to have_content("Discount Applied!")
        expect(page).to have_link("See Discount #{bd_1.id}'s Info")
        click_on "See Discount #{bd_1.id}'s Info"
      end
      expect(current_path).to eq("/merchants/#{merchant1.id}/bulk_discounts/#{bd_1.id}")
    end
  end
end

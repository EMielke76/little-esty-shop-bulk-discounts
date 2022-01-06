require 'rails_helper'

RSpec.describe 'The Admin Dashboard page' do
  it 'shows a header to notify the dashboard' do
    visit "/admin"

    expect(page).to have_content("Admin Dashboard")
  end

  it 'shows links to access merchant and invoice index' do
    visit "/admin"

    expect(page).to have_link("Merchants Index")
    expect(page).to have_link("Invoices Index")
  end

  it 'shows the names of the top 5 customers ' do
    customer_1 = create(:customer, first_name: 'Bob', last_name: "Smith")
    customer_2 = create(:customer, first_name: 'John', last_name: "Charles")
    customer_3 = create(:customer, first_name: 'Abe', last_name: "McConnel")
    customer_4 = create(:customer, first_name: 'Zach', last_name: "Doe")
    customer_5 = create(:customer, first_name: 'Charlie', last_name: "Rey")

    merchant_1 = create(:merchant_with_invoices, invoice_count: 6, customer: customer_1, invoice_status: 2)
    merchant_2 = create(:merchant_with_invoices, invoice_count: 3, customer: customer_2, invoice_status: 2)
    merchant_3 = create(:merchant_with_invoices, invoice_count: 8, customer: customer_3, invoice_status: 2)
    merchant_4 = create(:merchant_with_invoices, invoice_count: 1, customer: customer_4, invoice_status: 2)
    merchant_5 = create(:merchant_with_invoices, invoice_count: 4, customer: customer_5, invoice_status: 2)

    visit "/admin"
    expect(page).to have_content("Top 5 Customers")

    expect('Abe McConnel').to appear_before('Bob Smith')
    expect('Bob Smith').to appear_before('Charlie Rey')
    expect('Charlie Rey').to appear_before('John Charles')
    expect('John Charles').to appear_before('Zach Doe')

    expect(page).to have_content("Abe McConnel with 8 completed transactions")
    expect(page).to have_content("Zach Doe with 1 completed transactions")
  end
end

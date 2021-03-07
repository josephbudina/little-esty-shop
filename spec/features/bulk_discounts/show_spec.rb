require "rails_helper"

RSpec.describe "Bulk Discounts Index" do
  before :each do
    @merchant1 = create(:merchant)
    @item1 = create(:item, merchant_id: @merchant1.id)
    @item2 = create(:item, merchant_id: @merchant1.id)

    @customers = []
    10.times {@customers << create(:customer)}
    @customers.each do |customer|
      create(:invoice, customer_id: customer.id)
    end

    @invoice_1 = @customers.first.invoices.first
    @invoice_2 = @customers.second.invoices.first
    @invoice_3 = @customers.third.invoices.first
    @invoice_4 = @customers.fourth.invoices.first
    @invoice_5 = @customers.fifth.invoices.first
    @invoice_6 = @customers[5].invoices.first
    @invoice_7 = @customers[6].invoices.first

    9.times {create(:transaction, invoice_id: @invoice_1.id, result: 0)}
    8.times {create(:transaction, invoice_id: @invoice_2.id, result: 0)}
    7.times {create(:transaction, invoice_id: @invoice_3.id, result: 0)}
    6.times {create(:transaction, invoice_id: @invoice_4.id, result: 0)}
    1.times {create(:transaction, invoice_id: @invoice_5.id, result: 0)}
    1.times {create(:transaction, invoice_id: @invoice_6.id, result: 1)}
    10.times {create(:transaction, invoice_id: @invoice_7.id, result: 1)}

    @invoice_item_1 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_1.id, status: 0)
    @invoice_item_2 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_2.id, status: 0)
    @invoice_item_3 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_3.id, status: 1)
    @invoice_item_4 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_4.id, status: 2)
    @invoice_item_5 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_5.id, status: 0)

    @bulk_discount_1 = @merchant1.bulk_discounts.create(percentage_discount: 20, threshold: 10)
    @bulk_discount_2 = @merchant1.bulk_discounts.create(percentage_discount: 30, threshold: 10)
    @bulk_discount_3 = @merchant1.bulk_discounts.create(percentage_discount: 40, threshold: 10)
  end

  it 'shows a bulk discounts attributes' do
    visit merchant_bulk_discount_path(@merchant1, @bulk_discount_1)

    expect(page).to have_content(@bulk_discount_1.percentage_discount)
    expect(page).to have_content(@bulk_discount_1.threshold)
  end
end
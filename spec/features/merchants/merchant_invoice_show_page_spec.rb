require 'rails_helper'

RSpec.describe "Merchant Invoice Show Page" do
  before :each do
    @merchant = Merchant.create(name: "John's Jewelry")
    @not_merchant = Merchant.create(name: "Mikey Mouse Rings")
    @bulk_discount = @not_merchant.bulk_discounts.create(percentage_discount: 20, threshold: 10)
    @not_item = @not_merchant.items.create(name: "Mouse Ring", description: "Oh Toodles", unit_price: 12.99)
    @item1 = @merchant.items.create(name: "Gold Ring", description: "14K Wedding Band",
                                  unit_price: 599.95)
    @item2 = @merchant.items.create(name: "Pearl Necklace", description: "Beautiful White Pearls",
                                  unit_price: 250.00)
    @customer = Customer.create!(first_name: "Bob", last_name: "Jones")
    @not_customer = Customer.create!(first_name: "Mike", last_name: "Jones")
    @invoice1 = @customer.invoices.create(status: 0)
    @invoice2 = @customer.invoices.create(status: 1)
    @invoice_item1 = @invoice1.invoice_items.create!(invoice_id: @invoice1.id,
                                       item_id: @item1.id, quantity: 500,
                                       unit_price: 599.95, status: 0)
    @invoice_item2 = @invoice1.invoice_items.create!(invoice_id: @invoice1.id,
                                       item_id: @item2.id, quantity: 2,
                                       unit_price: 250.00, status: 0)
    @not_invoice_item = @invoice1.invoice_items.create!(invoice_id: @invoice2.id,
                                       item_id: @not_item.id, quantity: 976,
                                       unit_price: 10.00, status: 1)
    @bulk_discount_1 = @merchant.bulk_discounts.create(percentage_discount: 20, threshold: 2)
    @bulk_discount_2 = @merchant.bulk_discounts.create(percentage_discount: 30, threshold: 1)
    @bulk_discount_3 = @merchant.bulk_discounts.create(percentage_discount: 40, threshold: 10)
  end

  describe 'total revenue includes discounts' do
    it 'includes discounted revenue' do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}"

      within("#invoice-total-revenue") do
        expect(page).to have_content("Total Revenue: $310235")
        expect(page).to have_content("Bulk Discount Revenue: $188143.0")
      end
    end
  end

  describe 'link to applied discounts' do
    it 'has links to bulk discount' do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}"

      within("#invoice-items-#{@invoice_item1.id}-info") do
        expect(page).to have_link("Discount Applied")
        expect(page).to_not have_link("No Discount")

        click_link 'Discount Applied'
      end
      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bulk_discount_3.id}")
    end
  end

  describe "When I visit my merchant's invoice show page(/merchants/merchant_id/invoices/invoice_id)" do
    it "I see the invoice attributes listed" do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}"
        within "#invoice-info" do
          expect(page).to have_content(@invoice1.id)
          expect(page).to have_content(@invoice1.status_format)
          expect(page).to have_content(@invoice1.date_format)
        end
      end
    end

    it "I see all of the customer information related to that invoice " do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}"
        within "#invoice-customer-info" do
          expect(page).to have_content(@customer.name)
          expect(page).to_not have_content(@not_customer.name)
      end
    end

    it "Then I see all of my items on the invoice(item name, quantity, price sold, invoice item status)" do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}" do
        # expect(page).to_not have_content(@not_item.name)
        # expect(page).to_not have_content(@not_invoice_item.quantity)
        # expect(page).to_not have_content(@not_invoice_item.unit_price)
        within "#invoice-items-#{@invoice_item1.id}-info" do
          expect(page).to have_content(@item1.name)
          expect(page).to have_content(@invoice_item1.quantity)
          expect(page).to have_content(@invoice_item1.unit_price)
          expect(page).to have_content(@invoice_item1.status.titleize)
        end
        within "#invoice-items-#{@invoice_item2.id}-info" do
          expect(page).to have_content(@item2.name)
          expect(page).to have_content(@invoice_item2.quantity)
          expect(page).to have_content(@invoice_item2.unit_price)
          expect(page).to have_content(@invoice_item2.status.titleize)
        end
      end
    end

    it "I see the total revenue that will be generated from all of my items on the invoice" do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}"
        within "#invoice-total-revenue" do
          expect(page).to have_content(@invoice1.total_revenue)
      end
    end

    it "I see that each invoice item status is a select field and can be updated with a button" do
      visit "/merchant/#{@merchant.id}/invoices/#{@invoice1.id}"
        within "#invoice-items-#{@invoice_item1.id}-info" do
          expect(page).to have_button("Update Item Status")
          select('Shipped', from: 'status')
          click_button("Update Item Status")
          expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/#{@invoice1.id}")
          expect(page).to have_content('Shipped')
        end
      end
end
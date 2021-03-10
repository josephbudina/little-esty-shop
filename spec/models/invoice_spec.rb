require 'rails_helper'

RSpec.describe Invoice, type: :model do
  before :each do
    @customer1 = Customer.create(first_name: "Joe",
                                 last_name: "Smith")
    @invoice1 = @customer1.invoices.create(status: 0)
    @invoice2 = @customer1.invoices.create(status: 1)
    @invoice3 = @customer1.invoices.create(status: 2)
    @invoice4 = @customer1.invoices.create(status: 0)

    @merchant = Merchant.create(name: "John's Jewelry")
    @item1 = @merchant.items.create(name: "Gold Ring", description: "14K Wedding Band",
                                    unit_price: 599.95)
    @item2 = @merchant.items.create(name: "Diamond Ring", description: "Shiny",
                                    unit_price: 1000.00)
    @item3 = @merchant.items.create(name: "Silver Ring", description: "Plain",
                                    unit_price: 350.00)
    @item4 = @merchant.items.create(name: "Mood Ring", description: "Strong mood vibes",
                                    unit_price: 100.00)
    @invoice_item1 = InvoiceItem.create!(invoice_id: @invoice1.id,
                                         item_id: @item1.id, quantity: 500,
                                         unit_price: 599.95, status: 0)
    @invoice_item2 = InvoiceItem.create!(invoice_id: @invoice2.id,
                                         item_id: @item2.id, quantity: 200,
                                         unit_price: 1000.00, status: 0)
    @invoice_item3 = InvoiceItem.create!(invoice_id: @invoice3.id,
                                         item_id: @item1.id, quantity: 100,
                                         unit_price: 350.00, status: 0)
    @invoice_item4 = InvoiceItem.create!(invoice_id: @invoice4.id,
                                         item_id: @item4.id, quantity: 400,
                                         unit_price: 100.00, status: 0)

  end

  describe "relationships" do
    it {should belong_to :customer}
    it {should have_many :invoice_items}
    it {should have_many(:items).through(:invoice_items)}
  end

  describe "different statuses" do
    it 'can display in progress' do
      expect(@invoice1.status).to eq("in progress")
      expect(@invoice1.status).to_not eq("cancelled")
      expect(@invoice1.status).to_not eq("completed")
    end

    it 'can display completed' do
      expect(@invoice2.status).to eq("completed")
      expect(@invoice2.status).to_not eq("cancelled")
      expect(@invoice2.status).to_not eq("in progress")
    end

    it 'can display cancelled' do
      expect(@invoice3.status).to eq("cancelled")
      expect(@invoice3.status).to_not eq("completed")
      expect(@invoice3.status).to_not eq("in progress")
    end
  end

  describe "instance methods" do
    describe '#bulk_discount_application' do
      it 'applys bulk discount to items' do
        @merchant1 = create(:merchant)

        @item1 = create(:item, merchant_id: @merchant1.id)
        @item2 = create(:item, merchant_id: @merchant1.id)
        @item3 = create(:item, merchant_id: @merchant1.id)
        @customer1 = create(:customer, first_name: "dan")
        @invoice_1 = create(:invoice, customer_id: @customer1.id)
        @invoice_item_1 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_1.id, status: 0, quantity: 5, unit_price: 50.0)
        @invoice_item_2 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_1.id, status: 0, quantity: 12, unit_price: 60.54)
        @invoice_item_3 = create(:invoice_item, item_id: @item3.id, invoice_id: @invoice_1.id, status: 0, quantity: 10, unit_price: 90.7)
        @bulk_discount_1 = @merchant1.bulk_discounts.create(percentage_discount: 20, threshold: 2)
        @bulk_discount_2 = @merchant1.bulk_discounts.create(percentage_discount: 30, threshold: 1)
        @bulk_discount_3 = @merchant1.bulk_discounts.create(percentage_discount: 40, threshold: 10)

        expect(@invoice_1.apply_discount.uniq).to eq([@invoice_item_3, @invoice_item_2, @invoice_item_1])
      end

      it 'finds_discount' do
        @merchant1 = create(:merchant)
        @item1 = create(:item, merchant_id: @merchant1.id)
        @item2 = create(:item, merchant_id: @merchant1.id)
        @item3 = create(:item, merchant_id: @merchant1.id)
        @customer1 = create(:customer, first_name: "dan")
        @invoice_1 = create(:invoice, customer_id: @customer1.id)
        @invoice_item_1 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_1.id, status: 0, quantity: 5, unit_price: 50.0)
        @invoice_item_2 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_1.id, status: 0, quantity: 12, unit_price: 60.54)
        @invoice_item_3 = create(:invoice_item, item_id: @item3.id, invoice_id: @invoice_1.id, status: 0, quantity: 1, unit_price: 90.7)
        @bulk_discount_1 = @merchant1.bulk_discounts.create(percentage_discount: 20, threshold: 2)
        @bulk_discount_2 = @merchant1.bulk_discounts.create(percentage_discount: 30, threshold: 3)
        @bulk_discount_3 = @merchant1.bulk_discounts.create(percentage_discount: 40, threshold: 10)
        expect(@invoice_1.find_discount(@invoice_item_3.id)).to eq(0)
        expect(@invoice_1.find_discount(@invoice_item_1.id)).to eq(75.0)
      end

      it 'finds discount revenue' do
        @merchant1 = create(:merchant)
        @item1 = create(:item, merchant_id: @merchant1.id)
        @item2 = create(:item, merchant_id: @merchant1.id)
        @item3 = create(:item, merchant_id: @merchant1.id)
        @customer1 = create(:customer, first_name: "dan")
        @customer2 = create(:customer, first_name: "Jim")
        @invoice_1 = create(:invoice, customer_id: @customer1.id)
        @invoice_item_1 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_1.id, status: 0, quantity: 5, unit_price: 50.0)
        @invoice_item_2 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_1.id, status: 0, quantity: 12, unit_price: 60.54)
        @invoice_item_3 = create(:invoice_item, item_id: @item3.id, invoice_id: @invoice_1.id, status: 0, quantity: 10, unit_price: 90.7)
        @bulk_discount_1 = @merchant1.bulk_discounts.create(percentage_discount: 20, threshold: 2)
        @bulk_discount_2 = @merchant1.bulk_discounts.create(percentage_discount: 30, threshold: 1)
        @bulk_discount_3 = @merchant1.bulk_discounts.create(percentage_discount: 40, threshold: 10)

        expect(@invoice_1.discount_revenue).to eq(1155.088)
      end
    end

    describe "#date_format" do
      it "returns the created_at attribute in string formatted properties ex Monday, July 18, 2019" do
        invoice = @customer1.invoices.create(status: 0,created_at: Time.new(2019, 07, 18))
        expect(invoice.date_format).to eq("Thursday, July 18, 2019")
      end
    end

    describe "#status_format" do
      it "returns the status with each first letter capitalized for every word" do
        expect(@invoice1.status_format).to eq("In Progress")
        expect(@invoice2.status_format).to eq("Completed")
        expect(@invoice3.status_format).to eq("Cancelled")
      end
    end

    describe "#total_revenue" do
      it "returns total sum of the invoice_item quanity * invoice_item unit_price " do
        expect(@invoice1.total_revenue.round(2)).to eq(299975.00)
      end
    end

    describe "class methods" do
      describe "::not_shipped" do
        it "returns the invoices that have not been shipped and orders them from oldest to newest" do
          expect(@customer1.invoices.not_shipped[0]).to eq(@invoice1)
          expect(@customer1.invoices.not_shipped[-1]).to eq(@invoice4)
          expect(@customer1.invoices.not_shipped).to eq([@invoice1, @invoice2, @invoice3, @invoice4])
        end
      end
    end
  end
end

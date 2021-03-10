require "rails_helper"

RSpec.describe InvoiceItem, type: :model do

  describe "relationships" do
    it {should belong_to :invoice}
    it {should belong_to :item}
  end

  describe "different invoice item statuses" do
    it 'can display in pending' do
      expect(@invoice_item1.status).to eq("pending")
      expect(@invoice_item1.status).to_not eq("packaged")
      expect(@invoice_item1.status).to_not eq("shipped")
    end

    it 'can display packaged' do
      expect(@invoice_item3.status).to eq("packaged")
      expect(@invoice_item3.status).to_not eq("pending")
      expect(@invoice_item3.status).to_not eq("shipped")
    end

    it 'can display shipped' do
      expect(@invoice_item2.status).to eq("shipped")
      expect(@invoice_item2.status).to_not eq("packaged")
      expect(@invoice_item2.status).to_not eq("pending")
    end
  end

  describe "instance methods" do
    describe "#change_status" do
      it "updates the status of an invoice item" do
        expect(@invoice_item2.status).to eq("shipped")
        @invoice_item2.change_status('pending')
        expect(@invoice_item2.status).to eq("pending")
        expect(@invoice_item2.status).to_not eq("shipped")
      end
    end

    it 'applies discount' do
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

      expect(@invoice_item_1.applied).to eq(@bulk_discount_2)
      expect(@invoice_item_2.applied).to eq(@bulk_discount_3)
      expect(@invoice_item_3.applied).to eq(@bulk_discount_3)
    end

    it 'applies discount' do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @item1 = create(:item, merchant_id: @merchant1.id)
      @item2 = create(:item, merchant_id: @merchant1.id)
      @item3 = create(:item, merchant_id: @merchant1.id)
      @item4 = create(:item, merchant_id: @merchant2.id)
      @customer1 = create(:customer, first_name: "dan")
      @customer2 = create(:customer, first_name: "Jim")
      @invoice_1 = create(:invoice, customer_id: @customer1.id)
      @invoice_item_1 = create(:invoice_item, item_id: @item1.id, invoice_id: @invoice_1.id, status: 0, quantity: 5, unit_price: 50.0)
      @invoice_item_2 = create(:invoice_item, item_id: @item2.id, invoice_id: @invoice_1.id, status: 0, quantity: 12, unit_price: 60.54)
      @invoice_item_3 = create(:invoice_item, item_id: @item3.id, invoice_id: @invoice_1.id, status: 0, quantity: 10, unit_price: 90.7)
      @invoice_item_4 = create(:invoice_item, item_id: @item4.id, invoice_id: @invoice_1.id, status: 0, quantity: 10, unit_price: 90.7)
      @bulk_discount_1 = @merchant1.bulk_discounts.create(percentage_discount: 20, threshold: 2)
      @bulk_discount_2 = @merchant1.bulk_discounts.create(percentage_discount: 30, threshold: 1)
      @bulk_discount_3 = @merchant1.bulk_discounts.create(percentage_discount: 40, threshold: 10)

      expect(@invoice_item_1.applied_discount).to eq("discount_link")
      expect(@invoice_item_4.applied_discount).to eq("no_discount")
    end
  end

  describe "class methods" do
    describe "::calculate_revenue" do
      it "can return the total revenue for invoice items" do
        sum = ((@invoice_item1.unit_price * @invoice_item1.quantity) +
        (@invoice_item2.unit_price * @invoice_item2.quantity) +
        (@invoice_item3.unit_price * @invoice_item3.quantity))
        
        expect(InvoiceItem.calculate_revenue).to eq(sum)
      end
    end
  end

  before :each do
    @customer1 = Customer.create(first_name: "Joe", last_name: "Smith")
    @merchant1 = Merchant.create(name: "Pawtrait Designs")
    @item1 = @merchant1.items.create(name: "Puppy Portrait",
                                     description: "Wall art of your favorite pup",
                                     unit_price: 10.99)
    @item2 = @merchant1.items.create(name: "Kitty Portrait",
                                     description: "5x7 of your favorite cat",
                                     unit_price: 6.99)
    @item3 = @merchant1.items.create(name: "Pet Portrait",
                                     description: "8x10 of all your favorite pets",
                                     unit_price: 8.99)
    @invoice1 = @customer1.invoices.create(status: 0)
    @invoice2 = @customer1.invoices.create(status: 1)
    @invoice3 = @customer1.invoices.create(status: 2)
    @invoice_item1 = InvoiceItem.create(item_id: @item1.id,
                                        invoice_id: @invoice1.id,
                                        quantity: 100,
                                        unit_price: 10.99,
                                        status: 0)
    @invoice_item2 = InvoiceItem.create(item_id: @item1.id,
                                        invoice_id: @invoice1.id,
                                        quantity: 100,
                                        unit_price: 10.99,
                                        status: 2)
    @invoice_item3 = InvoiceItem.create(item_id: @item2.id,
                                        invoice_id: @invoice2.id,
                                        quantity: 500,
                                        unit_price: 6.99,
                                        status: 1)
  end
end

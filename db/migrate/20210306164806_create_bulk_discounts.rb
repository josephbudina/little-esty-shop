class CreateBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.references :merchant, foreign_key: true
      t.integer :percentage_discount
      t.integer :threshold

      t.timestamps
    end
  end
end

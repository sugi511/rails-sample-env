class CreateDeals < ActiveRecord::Migration[6.1]
  def change
    create_table :deals do |t|
      t.references :transaction, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.decimal :price
      t.integer :quantity
      t.references :vat_rate, null: false, foreign_key: true

      t.timestamps
    end
  end
end

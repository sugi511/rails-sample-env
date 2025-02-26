class CreateVatRates < ActiveRecord::Migration[6.1]
  def change
    create_table :vat_rates do |t|
      t.decimal :rate
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end

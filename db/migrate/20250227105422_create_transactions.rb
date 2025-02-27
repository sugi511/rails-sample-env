class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.datetime :transaction_date

      t.timestamps
    end
  end
end

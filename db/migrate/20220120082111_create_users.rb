class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.string :name, default: "", null: false
      t.string :api_key, default: "", null: false
      t.string :api_secret, default: "", null: false
      t.timestamps
    end
  end
end

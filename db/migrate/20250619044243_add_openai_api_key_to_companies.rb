class AddOpenaiApiKeyToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :openai_api_key, :string
  end
end

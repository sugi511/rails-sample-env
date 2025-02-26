# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#
# Indexes
#
#  index_items_on_company_id  (company_id)
#
# Foreign Keys
#
#  company_id  (company_id => companies.id)
#
class Item < ApplicationRecord
  belongs_to :company
  has_many :vat_rates, dependent: :destroy
end

# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#  region_id  :integer
#
# Indexes
#
#  index_customers_on_company_id  (company_id)
#  index_customers_on_region_id   (region_id)
#
# Foreign Keys
#
#  company_id  (company_id => companies.id)
#  region_id   (region_id => regions.id)
#
require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

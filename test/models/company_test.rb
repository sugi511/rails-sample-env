# == Schema Information
#
# Table name: companies
#
#  id                      :integer          not null, primary key
#  daily_request_limit_api :integer          default(100)
#  name                    :string           default(""), not null
#  openai_api_key          :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

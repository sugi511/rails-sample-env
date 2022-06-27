# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  api_key    :string           default(""), not null
#  api_secret :string           default(""), not null
#  name       :string           default(""), not null
#  top_secret :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#
# Indexes
#
#  index_users_on_company_id  (company_id)
#
class User < ApplicationRecord
  belongs_to :company
  has_many :surveys

  def set_api_credentials
    self.api_key = SecureRandom.hex(32)
    self.api_secret = SecureRandom.hex(32)
  end
end

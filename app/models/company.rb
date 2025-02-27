# == Schema Information
#
# Table name: companies
#
#  id                      :integer          not null, primary key
#  daily_request_limit_api :integer          default(100)
#  name                    :string           default(""), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class Company < ApplicationRecord
  has_many :gcra_settings, dependent: :destroy
  has_many :api_request_logs, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :surveys, dependent: :destroy
  has_many :regions, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :transactions, dependent: :destroy
end

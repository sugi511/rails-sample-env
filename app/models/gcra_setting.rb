# == Schema Information
#
# Table name: gcra_settings
#
#  id                :integer          not null, primary key
#  bucket_size       :integer          default(10), not null
#  emission_interval :integer          default(2), not null
#  name              :string           default("Limitatio in 10 mins"), not null
#  tat               :datetime         default(Sat, 01 Jan 2000 00:00:00.000000000 UTC +00:00), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :integer
#
# Indexes
#
#  index_gcra_settings_on_company_id  (company_id)
#
# Foreign Keys
#
#  company_id  (company_id => companies.id)
#
class GcraSetting < ApplicationRecord
  belongs_to :company

  def max_process_time
    bucket_size * emission_interval # cellの排出までの最大時間
  end
end

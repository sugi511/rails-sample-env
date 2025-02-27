# == Schema Information
#
# Table name: deals
#
#  id             :integer          not null, primary key
#  price          :decimal(, )
#  quantity       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  item_id        :integer          not null
#  transaction_id :integer          not null
#  vat_rate_id    :integer          not null
#
# Indexes
#
#  index_deals_on_item_id         (item_id)
#  index_deals_on_transaction_id  (transaction_id)
#  index_deals_on_vat_rate_id     (vat_rate_id)
#
# Foreign Keys
#
#  item_id         (item_id => items.id)
#  transaction_id  (transaction_id => transactions.id)
#  vat_rate_id     (vat_rate_id => vat_rates.id)
#
class Deal < ApplicationRecord
  belongs_to :sales_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :item
  belongs_to :vat_rate

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than: 0 }

  # Calculate total amount excluding VAT for a deal
  def total_excl_vat
    price * quantity
  end

  # Calculate total amount including VAT for a deal
  def total_incl_vat
    total_excl_vat * (1 + vat_rate.rate / 100.0)
  end
end

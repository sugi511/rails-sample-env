json.array! @vat_rates do |vat_rate|
  json.extract! vat_rate, :id, :rate
  json.url company_item_vat_rate_url(@item.company, @item, vat_rate, format: :json)
end

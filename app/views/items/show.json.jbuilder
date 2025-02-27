json.extract! @item, :id, :name
json.url company_item_url(@company, @item, format: :json)

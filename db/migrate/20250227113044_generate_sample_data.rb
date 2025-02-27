class GenerateSampleData < ActiveRecord::Migration[6.1]
  def up
    company = Company.first
    users = User.all
    customers = Customer.all
    items = Item.includes(:vat_rates).all

    if users.empty? || customers.empty? || items.empty?
      puts "Skipping transaction generation: missing users, customers, or items."
      return
    end

    (1..90).each do |day|
      200.times do
        transaction = Transaction.create!(
          company: company,
          user: users.sample,
          customer: customers.sample,
          transaction_date: day.days.ago
        )

        rand(1..5).times do
          item = items.sample
          vat_rate = item.vat_rates.sample
          
          next if vat_rate.nil?

          Deal.create!(
            sales_transaction: transaction,
            item: item,
            vat_rate: vat_rate,
            price: rand(10..100),
            quantity: rand(1..10)
          )
        end
      end
    end
  end

  def down
    Transaction.destroy_all
  end
end

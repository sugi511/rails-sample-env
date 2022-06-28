class AddOtpSecretColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp_secret, :string, default: '', null: false
  end
end

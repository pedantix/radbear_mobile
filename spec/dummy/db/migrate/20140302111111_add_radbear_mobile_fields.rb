class AddRadbearMobileFields < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :device_id, :string, :references => nil
    add_column :users, :current_device_type, :string
    add_column :users, :current_mac_address, :string
    add_column :users, :longitude, :float
    add_column :users, :latitude, :float
    add_column :users, :account_verified, :boolean, :null => false, :default => false
        
    add_index :users, :authentication_token, :unique => true
  end
end
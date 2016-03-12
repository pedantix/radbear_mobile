class AddPlatformAndVersionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_client_platform, :string
    add_column :users, :mobile_client_version, :string
  end
end

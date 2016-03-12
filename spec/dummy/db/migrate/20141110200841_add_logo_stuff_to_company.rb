class AddLogoStuffToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :company_logo_includes_name, :boolean, null: false, default: false
    add_column :companies, :app_logo_includes_name, :boolean, null: false, default: false
  end
end

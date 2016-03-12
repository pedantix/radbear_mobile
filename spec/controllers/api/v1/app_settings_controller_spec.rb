require 'spec_helper'

describe Api::V1::AppSettingsController, :type => :controller do
  render_views
  
  describe "index" do
    it "should get the settings" do
      get :index
      expect(response.status).to be(200)
      
      json = JSON.parse(response.body)
      expect(json["company_email"]).to eq(Company.main.email)
      expect(json["use_avatar"]).to eq(Rails.configuration.use_avatar)
    end
  end
  
end
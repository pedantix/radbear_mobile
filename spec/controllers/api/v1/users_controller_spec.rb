require 'spec_helper'

describe Api::V1::UsersController, :type => :controller do
  render_views
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    @user.ensure_authentication_token
    @user.save!
  end
  
  def base_params
    {:auth_token => @user.authentication_token}
  end
  
  describe "index" do
    it "should get some user fields" do
      auth_token = @user.authentication_token
      users = User.where("authentication_token = ?", auth_token)
      get :index, base_params
      expect(response.status).to be(200)
      
      json = JSON.parse(response.body)
      expect(json["users"].first["email"]).to eq(@user.email)
      expect(json["users"].first["created_at"].to_date).to eq(@user.created_at.to_s.to_date)
      expect(json["users"].first["admin"]).to eq(@user.admin)
    end
  end
  
  describe "update" do
    it "should update the user" do
      if Rails.configuration.use_first_name
        new_name = Faker::Name.first_name
        put :update, {:id => @user.id, :user => {:first_name => new_name}}.merge(base_params)
        expect(response.status).to be(200)
        expect(User.find(@user.id).first_name).to eq(new_name)
      end
      
      if Rails.configuration.use_username
        new_name = Faker::Internet.user_name
        put :update, {:id => @user.id, :user => {:username => new_name}}.merge(base_params)
        expect(response.status).to be(200)
        expect(User.find(@user.id).username).to eq(new_name)
      end
      
    end
  end
  
end
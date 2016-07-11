require 'spec_helper'

describe Api::V1::TokensController, :type => :controller do
  render_views

  let(:user) { create :user }

  before(:each) do
    @device_id = Faker::Internet.user_name
  end
  
  def base_params
    {platform: "iOS", version: "1.0"}
  end
  
  describe "create" do
    
    it "should login with device id" do
      request.accept = "application/json"
      post :create, params: {:device_id => @device_id, :device_type => "Nexus S"}.merge(base_params)
      expect(response.status).to be(Rails.application.config.allow_frictionless_registration ? 200 : 400)
      
      if Rails.application.config.allow_frictionless_registration
        json = JSON.parse(response.body)
        expect(json["users"].first["email"]).to eq("#{@device_id}@radicalbear.com")
      end
    end
    
    it "should login with email and pw and then facebook" do
      if Rails.configuration.enable_facebook
        facebook = Koala::Facebook::TestUsers.new(:app_id => Rails.application.config.fb_app_id, :secret => Rails.application.config.fb_app_secret)
        fb_user = facebook.create(true, "email, publish_actions")
        email = fb_user["email"]
        user = create(:user, :email => email)
      
        request.accept = "application/json"
        post :create, params: {:device_id => @device_id, :email => email, :password => "password"}.merge(base_params)
        expect(response.status).to be(200)
      
        json = JSON.parse(response.body)

        expect(json["users"].first["email"]).to eq(email)

        post :create, params: {:facebook_access_token => fb_user["access_token"], :device_id => @device_id}.merge(base_params)
        expect(response.status).to be(200)
      end
    end
    
    it "should login with email and log in again with a different email if frictionless" do
      email = Faker::Internet.email
      
      request.accept = "application/json"
      post :create, params: {:device_id => @device_id, :email => email, :password => "password"}.merge(base_params)
      expect(response.status).to be(Rails.application.config.allow_frictionless_registration ? 200 : 401)
      
      if Rails.application.config.allow_frictionless_registration
        json = JSON.parse(response.body)
        expect(json["users"].first["email"]).to eq(email)
      end
      
      post :create, params: {:device_id => @device_id, :email => Faker::Internet.email, :password => "password"}.merge(base_params)
      expect(response.status).to be(Rails.application.config.allow_frictionless_registration ? 200 : 401)
    end
    
    it "should login with Facebook credentials and then log in again" do
      if Rails.configuration.enable_facebook
        facebook = Koala::Facebook::TestUsers.new(:app_id => Rails.application.config.fb_app_id, :secret => Rails.application.config.fb_app_secret)
        fb_user = facebook.create(true, "email, publish_actions")
      
        request.accept = "application/json"
        post :create, params: {:facebook_access_token => fb_user["access_token"], :device_id => @device_id}.merge(base_params)

        expect(response.status).to be(200)
        json = JSON.parse(response.body)
        expect(json["users"].first["email"]).to eq(fb_user["email"])
      
        post :create, params: {:facebook_access_token => fb_user["access_token"], :device_id => @device_id}.merge(base_params)
        expect(response.status).to be(200)
      end
    end
    
    it "should get error with incorrect login" do
      user = FactoryGirl.create(:user, :email => Faker::Internet.email)      
      request.accept = "application/json"
      
      post :create, params: {:device_id => @device_id, :email => user.email, :password => "password"}.merge(base_params)
      expect(response.status).to be(200)
      
      post :create, params: {:device_id => @device_id, :email => user.email, :password => "blah"}.merge(base_params)
      expect(response.status).to be(401)
    end
    
    it "should get error if unconfirmed" do
      if RadbearMobile.devise_confirmable?
        user.confirmed_at = nil
        user.save!
    
        request.accept = "application/json"
        post :create, params: {:device_id => @device_id, :email => user.email, :password => "password"}.merge(base_params)
        expect(response.status).to be(401)
      end
    end
    
    it "should get error if not json" do
      post :create, params: {:device_id => @device_id, :email => Faker::Internet.email, :password => "password"}.merge(base_params)
      expect(response.status).to be(406)
    end
    
    it "should truncate device type if too long" do
      user = create :user, email: Faker::Internet.email
      too_long = Faker::Lorem.characters(300)
      request.accept = "application/json"
      post :create, params: {:device_id => @device_id, :device_type => too_long, :email => user.email, :password => "password"}.merge(base_params)
      expect(response.status).to be(200)
      json = JSON.parse(response.body)
      user.reload
      expect(user.current_device_type).to eq(too_long[0,255])
    end

  end
  
  describe "delete" do

    before { sign_in user }

    it "should delete the token" do
      sign_in user
      
      request.accept = "application/json"
      post :create, params: {:device_id => @device_id, :email => user.email, :password => "password"}.merge(base_params)
      json = JSON.parse(response.body)

      delete :destroy, params: {:id => json["users"].first["authentication_token"], :user_id => json["users"].first["id"]}
      expect(response.status).to be(200)
    end
  end
end

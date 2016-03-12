require 'spec_helper'

describe "Users", :type => :request do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  def headers
    {'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json"}
  end

  describe "reset password" do
    it "should be successful" do
      post("users/password", {:user => {:email => @user.email}}, headers)
      expect(response.status).to be(201)
    end
    
    it "should fail with an invalid email address" do
      post("users/password", {:user => {:email => "thisisnotvalid@invalid.com"}}, headers)
      expect(response.status).to be(422)
      expect(response.body).to include("not found")
    end
  end
  
  describe "resend confirmation" do
    it "should be successful" do
      if RadbearMobile.devise_confirmable?
        @user.confirmed_at = nil
        @user.save!
        
        post("users/confirmation", {:user => {:email => @user.email}}, headers)
        expect(response.status).to be(201)
      end
    end
    
    it "should fail with an invalid email address" do
      if RadbearMobile.devise_confirmable?
        post("users/confirmation", {:user => {:email => "thisisnotvalid@invalid.com"}}, headers)
        expect(response.status).to be(422)
        expect(response.body).to include("not found")
      end
    end
  end

end

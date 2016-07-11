require 'spec_helper'

describe "Users", type: :request do
  
  let(:user) { create :user }

  let(:headers) do
    {'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json"}
  end

  describe "reset password" do
    it "should be successful" do
      post user_password_path,
         xhr: true,
         params: {:user => {:email => user.email}},
         headers: headers
      expect(response.status).to be(201)
    end
    
    it "should fail with an invalid email address" do
      post  user_password_path,
        xhr: true,
        params: { user: { email: "thisisnotvalid@invalid.com"}},
        headers: headers
      expect(response.status).to be(422)
      expect(response.body).to include("not found")
    end
  end
  
  describe "resend confirmation" do
    it "should be successful" do
      if RadbearMobile.devise_confirmable?
        user.confirmed_at = nil
        user.save!
        
        post user_confirmation_path,
          xhr: true,
          params: {:user => {:email => user.email}},
          headers: headers
        expect(response.status).to be(201)
      end
    end
    
    it "should fail with an invalid email address" do
      if RadbearMobile.devise_confirmable?
        post user_confirmation_path,
          xhr: true,
          params: {:user => {:email => "thisisnotvalid@invalid.com"}},
          headers: headers
        expect(response.status).to be(422)
        expect(response.body).to include("not found")
      end
    end
  end

end

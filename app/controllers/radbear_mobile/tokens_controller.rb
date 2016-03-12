require "koala"

module RadbearMobile
  class TokensController < RadbearMobile::ApplicationController
    skip_before_filter :verify_authenticity_token
    respond_to :json

    def create
      email = params[:email]
      password = params[:password]
      password_confirmation = params[:password_confirmation]
      first_name = params[:first_name]
      last_name = params[:last_name]
      facebook_access_token = params[:facebook_access_token]
      twitter_access_token = params[:twitter_access_token]
      twitter_access_secret = params[:twitter_access_secret]
      device_id = params[:device_id]
      platform = params[:platform]
      version = params[:version]

      if !valid_request?(device_id, email, password, facebook_access_token, twitter_access_token, twitter_access_secret, platform, version)
        return
      end

      account_verified = false

      if !facebook_access_token.blank?
        @current_api_user, message, account_verified = login_with_facebook(device_id, facebook_access_token)
      elsif !twitter_access_token.blank? && !twitter_access_secret.blank?
        @current_api_user, message, account_verified = login_with_twitter(device_id, twitter_access_token, twitter_access_secret, email)
      elsif !email.blank?
        if password_confirmation.blank?
          @current_api_user, message, account_verified = login_with_email(device_id, email, password)
        else
          @current_api_user, message, account_verified = signup_with_email(device_id, email, password, password_confirmation, first_name, last_name)
        end
      else
        @current_api_user, message, account_verified = login_with_device(device_id)
      end

      if message
        @current_api_user = nil
        logger.info("User #{device_id} failed signin: #{message}")
        render :status => 401, :json => {:message => message}
        return
      end

      if @current_api_user.nil?
        logger.info("User #{email} failed signin, user cannot be found.")
        render :status => 401, :json => {:message => "Invalid user"}
        return
      end

      if (RadbearMobile.devise_confirmable? && !@current_api_user.confirmed?)
        @current_api_user = nil
        render :status => 401, :json => {:message => "You have to confirm your account before continuing"}
        return
      end
      
      if (!@current_api_user.active_for_authentication?)
        message = t("devise.failure.#{@current_api_user.inactive_message}")
        @current_api_user = nil
        render :status => 401, :json => {:message => message}
        return
      end

      @current_api_user.ensure_authentication_token

      if params[:device_type].present? && !params[:device_type].blank?
        if @current_api_user.current_device_type != params[:device_type]
          if params[:device_type].length > 255
            @current_api_user.current_device_type = params[:device_type][0,255]
          else
            @current_api_user.current_device_type = params[:device_type]
          end
        end
      end
      
      @current_api_user.latitude = params[:latitude] if params[:latitude].present? && @current_api_user.respond_to?(:latitude)
      @current_api_user.longitude = params[:longitude] if params[:longitude].present? && @current_api_user.respond_to?(:longitude)
      @current_api_user.current_mac_address = params["mac_address"] if params["mac_address"].present?
      @current_api_user.account_verified = account_verified if @current_api_user.respond_to?(:account_verified)
      @current_api_user.mobile_client_platform = platform
      @current_api_user.mobile_client_version = version
      
      @current_api_user.save!
      
      @users = User.where("id = ?", @current_api_user.id)
    end

    def destroy
      @current_api_user = User.find_by_authentication_token_and_id(params[:id], params[:user_id])
      
      if @current_api_user
        @current_api_user.reset_authentication_token!
        sign_out(@current_api_user)
      end
      
      render :status => 200, :json => {:token => params[:id]}
    end

    private

      def valid_request?(device_id, email, password, facebook_access_token, twitter_access_token, twitter_access_secret, platform, version)
        if request.format != :json
          render :status=>406, :json => {:message => "Invalid request format, please contact support."}
          return false
        end
        
        if @api_removed == true
          render :status => 400, :json => {:message => "This version of the app is no longer supported, please upgrade."}
          return false
        end

        if device_id.blank?
          render :status => 400, :json => {:message => "Invalid device parameter, please contact support."}
          return false
        end

        if platform.blank? || version.blank?
          render :status => 400, :json => {:message => "Missing parameters, please contact support."}
          return false
        end

        if !email.blank? and !password.blank? and (!facebook_access_token.blank? or !twitter_access_token.blank? or !twitter_access_secret.blank?)
          render :status => 400, :json => {:message => "Invalid request parameters (001), please contact support."}
          return false
        end
        
        if !twitter_access_token.blank? and email.blank?
          render :status => 400, :json => {:message => "Invalid request parameters (002), please contact support."}
          return false
        end

        if email.blank? and facebook_access_token.blank? and twitter_access_token.blank? and !Rails.application.config.allow_frictionless_registration
          render :status => 400, :json => {:message => "Invalid request parameters (003), please contact support."}
          return false
        end

        return true
      end

      def login_with_facebook(device_id, access_token)
        begin
          graph = Koala::Facebook::API.new(access_token)
          me = graph.get_object("me?fields=id,first_name,last_name,gender,birthday,location,email,picture.width(200)")
        rescue Exception => e
          puts e.message
          return nil, "The facebook authentication is invalid, we have cleared your tokens, please try again.", false
        end

        if !me['email'].present? || me['email'].blank?
          return nil, "Could not get profile information from Facebook", false
        end

        email = me['email']
        uid = me['id']
        timezone = RadbearMobile.convert_timezone(me['timezone'])
        first_name = me["first_name"]
        last_name = me["last_name"]
        avatar = "https://graph.facebook.com/#{uid}/picture?type=large"

        location = me['location']['name'] if me['location']
        birthday = DateTime.strptime(me['birthday'], "%m/%d/%Y") if me['birthday']

        if me['gender']
          gender = "M" if me['gender'] == "male"
          gender = "F" if me['gender'] == "female"
        end

        options = {location: location, birthday: birthday, gender: gender}

        #todo get expires_at if possible and send below instead of nil
        return RadbearMobile.find_for_provider_oauth("facebook", uid, device_id, email, access_token, nil, nil, timezone, first_name, last_name, avatar, nil, options)
      end
      
      def login_with_twitter(device_id, access_token, access_secret, email)        
        begin
          client = Twitter::REST::Client.new do |config|
            config.consumer_key        = Rails.application.config.twitter_app_key
            config.consumer_secret     = Rails.application.config.twitter_app_secret
            config.access_token        = access_token
            config.access_token_secret = access_secret
          end
          
          me = client.user
        rescue Exception => e
          puts e.message
          return nil, "The twitter authentication is invalid, we have cleared your tokens, please try again.", false
        end

        if !me.id
          return nil, "Could not get profile information from Twitter", false
        end

        uid = me.id.to_s
        timezone = me.time_zone
        
        names = me.name.split(" ")
        if names.count > 0
          first_name = names[0]
        else
          first_name = "Unknown"
        end

        if names.count > 1
          last_name = names[1]
        else
          last_name = "Unknown"
        end
        
        avatar = me.profile_image_url.to_s

        return RadbearMobile.find_for_provider_oauth("twitter", uid, device_id, email, access_token, access_secret, nil, timezone, first_name, last_name, avatar, nil)
      end
      
      def signup_with_email(device_id, email, password, password_confirmation, first_name, last_name)
        user = User.new
        user.email = email
        user.device_id = device_id
        user.password = password
        user.password_confirmation = password_confirmation
        user.first_name = first_name
        user.last_name = last_name
        message = user.errors.full_messages.join(", ") if !user.save
        
        return user, message, message.nil?
      end

      def login_with_email(device_id, email, password)
        user = User.find_by_email(email.downcase)
        message = nil

        if user
          if user.valid_password?(password)
            user.device_id = device_id
            user.skip_reconfirmation! if RadbearMobile.devise_confirmable?
            message = user.errors.full_messages.join(", ") if !user.save
          else
            message = "Invalid email or password."
          end
        else
          if Rails.application.config.allow_frictionless_registration
            user = User.find_by_device_id(device_id)

            if user
              user.email = email
              user.password = password
              user.password_confirmation = password
              user.skip_reconfirmation! if RadbearMobile.devise_confirmable?
              message = user.errors.full_messages.join(", ") if !user.save
            else
              user = User.new
              user.email = email
              user.device_id = device_id
              user.password = password
              user.password_confirmation = password
              user.skip_confirmation! if RadbearMobile.devise_confirmable?
              message = user.errors.full_messages.join(", ") if !user.save
            end
          else
            message = "Invalid email or password."
          end
        end

        return user, message, message.nil?
      end

      def login_with_device(device_id)
        email = "#{device_id}@radicalbear.com"
        user = User.find_by_device_id(device_id) || User.find_by_email(email)
        message = nil

        if !user
          user = User.new
          user.email = email
          user.device_id = device_id
          user.password = Devise.friendly_token[0,20]
          user.skip_confirmation! if RadbearMobile.devise_confirmable?
          message = user.errors.full_messages.join(", ") if !user.save
        end

        return user, message, false

      end

  end
end
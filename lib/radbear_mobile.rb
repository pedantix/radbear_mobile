require "radbear_mobile/engine"

module RadbearMobile
  include ActionView::Helpers::TextHelper
  module_function :truncate
  
  class ApiConstraints
    def initialize(options)
      @version = options[:version]
      @default = options[:default]
      @app_name = options[:app_name] || Rails.application.class.parent_name.underscore
    end
    
    def matches?(req)
      @default || req.headers['Accept'] && req.headers['Accept'].include?("application/vnd.#{@app_name}.v#{@version}")
    end
  end

  def self.get_file_data_from_json(file_data, file_name, file_ext, content_type)
    data = StringIO.new(Base64.decode64(file_data))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = "#{file_name}.#{file_ext}"
    data.content_type = content_type
    return data
  end

  def self.handle_apn_devices(user_id, message, object_id, send_now)
    if object_id
      properties = {:object_id => object_id}
    else
      properties = nil
    end
    
    app = APN::App.first
    if app
      devices = APN::Device.where("user_id = ?", user_id)
      devices.each do |device|
        notification = APN::Notification.new
        notification.device = device
        notification.badge = 1
        notification.sound = true
        notification.alert = truncate(message, :length => 200) if message
        notification.custom_properties = properties if properties
        notification.save!
      end
      
      app.send_notifications if send_now
      
    end
  end

  def self.find_for_provider_oauth(provider, provider_id, device_id, email, access_token, access_secret, expires_at, timezone, first_name, last_name, avatar, current_user, options = {})
    message = nil
    
    if current_user
      message = update_provider_data(current_user, provider, provider_id, email, first_name, last_name, access_token, access_secret, timezone, expires_at, avatar, options)
      user = current_user
    else
      user = User.find_by_email(email)
      if user
        message = RadbearMobile.update_provider_data(user, provider, provider_id, email, first_name, last_name, access_token, access_secret, timezone, expires_at, avatar, options)
      else
        users = User.where("#{provider}_id = ?", provider_id)
        user = users.first if users.count != 0
        if user
          message = update_provider_data(user, provider, provider_id, email, first_name, last_name, access_token, access_secret, timezone, expires_at, avatar, options)
        else
          user = User.find_by_device_id(device_id) if device_id
          if user
            message = update_provider_data(user, provider, provider_id, email, first_name, last_name, access_token, access_secret, timezone, expires_at, avatar, options)
          else
            if Rails.application.config.enable_facebook
              user = User.new
              user.password = Devise.friendly_token[0,20]
              message = update_provider_data(user, provider, provider_id, email, first_name, last_name, access_token, access_secret, timezone, expires_at, avatar, options)
            else
              user = nil
              message = "You must first register as a user before connectiong this social media service to your account"
            end
          end
        end
      end
    end

    return user, message, message.nil?
  end

  def self.convert_timezone(raw_timezone)
    timezone = ""
        
    offset = raw_timezone.to_i
    
    #todo will need to determine whether the locale participates in dst or not, but for now this will work properly in the U.S.
    offset = offset - 1 if Time.now.in_time_zone("Eastern Time (US & Canada)").isdst
    
    if offset == -5
      timezone = "Eastern Time (US & Canada)"
    elsif offset == -6
      timezone = "Eastern Time (US & Canada)"
    elsif offset == -7
      timezone = "Mountain Time (US & Canada)"
    elsif offset == -8
      timezone = "Pacific Time (US & Canada)"
    else
      timezone = ActiveSupport::TimeZone.new(offset).name
    end

    timezone = default_timezone if timezone.blank?
    timezone      
  end

  def self.default_timezone
    "Eastern Time (US & Canada)"
  end

  def self.devise_confirmable?
    Devise.mappings[:user].confirmable?
  end

  private

    def self.update_provider_data(user, provider, provider_id, email, first_name, last_name, access_token, access_secret, timezone, expires_at, avatar, options = {})
      if devise_confirmable?
        if user.id
          user.skip_reconfirmation!
        else
          user.skip_confirmation!
        end
      end
      
      user.email = email
      user.timezone = timezone if timezone
      user.provider_avatar = avatar if avatar
      
      if !user.respond_to?(:profile_verified) || !user.profile_verified
        user.first_name = first_name
        user.last_name = last_name
      end

      if options
        user.city = options[:location] if user.respond_to?(:city) && options[:location]
        user.birthday = options[:birthday] if user.respond_to?(:birthday) && options[:birthday]
        user.gender = options[:gender] if user.respond_to?(:gender) && options[:gender]
      end
      
      user.send("#{provider}_id=", provider_id)
      user.send("#{provider}_access_token=", access_token)
      user.send("#{provider}_access_secret=", access_secret) if User.column_names.include?("#{provider}_access_secret")
      user.send("#{provider}_expires_at=", expires_at) if User.column_names.include?("#{provider}_expires_at")
      
      message = user.errors.full_messages.join(", ") if !user.save
    end

end
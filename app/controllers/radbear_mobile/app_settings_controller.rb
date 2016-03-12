module RadbearMobile
  class AppSettingsController < RadbearMobile::ApplicationController
    respond_to :json
    
    def index
      render json:  {
                      :enable_frictionless => Rails.application.config.allow_frictionless_registration,
                      :company_website => Company.main.website,
                      :company_email => Company.main.email,
                      :company_name => Company.main.name,
                      :enable_facebook => Rails.configuration.enable_facebook,
                      :enable_twitter => Rails.configuration.enable_twitter,
                      :enable_location => Rails.configuration.enable_location,
                      :enable_speed_test => Rails.configuration.enable_speed_test,
                      :use_first_name => Rails.configuration.use_first_name,
                      :use_last_name => Rails.configuration.use_last_name,
                      :use_mobile_phone => Rails.configuration.use_mobile_phone,
                      :use_username => Rails.configuration.use_username,
                      :signup_mode => Rails.configuration.signup_mode,
                      :use_avatar => Rails.configuration.use_avatar,
                      :enable_confirmation => RadbearMobile.devise_confirmable?
                    }, status: :ok
    end

  end
end
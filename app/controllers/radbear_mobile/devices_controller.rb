module RadbearMobile
  class DevicesController < RadbearMobile::ApplicationController
    before_filter :rb_token_auth
    respond_to :json
    
    def create
      handle_apn_device if params['device_token'].present?
      handle_gcm_device if params['gcm_registration_id'].present?
    end
    
    private

      def handle_apn_device
        device = ApnDevice.find_by_token(params['device_token'])
      
        if device
          if device.user_id == @current_api_user.id
            head :no_content
          else
            device.user_id = @current_api_user.id
          
            if device.save
              render json: { :device => device }, status: :created
            else
              render json: { :message => device.errors.full_messages.join(", ") }, status: :unprocessable_entity
            end
          end
        else
          device = ApnDevice.new
          device.user_id = @current_api_user.id
          device.token = params['device_token']

          if device.save
            render json: { :device => device }, status: :created
          else
            render json: { :message => device.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end
      end
      
      def handle_gcm_device
        device = GcmDevice.find_by_registration_id(params['gcm_registration_id'])

        if device
          if device.user_id == @current_api_user.id
            head :no_content
          else
            device.user_id = @current_api_user.id

            if device.save
              render json: { :device => device }, status: :created
            else
              render json: { :message => device.errors.full_messages.join(", ") }, status: :unprocessable_entity
            end
          end
        else
          device = GcmDevice.new
          device.user_id = @current_api_user.id
          device.registration_id = params['gcm_registration_id']

          if device.save
            render json: { :device => device }, status: :created
          else
            render json: { :message => device.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        end
      end

  end
end
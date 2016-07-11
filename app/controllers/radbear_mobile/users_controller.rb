module RadbearMobile
  class UsersController < RadbearMobile::ApplicationController
    include ActionView::Helpers::NumberHelper
    before_action :rb_token_auth
    
    respond_to :json
    
    def index
      @users = User.where("id = ?", @current_api_user.id)
    end

    def update
      if @current_api_user.update(permitted_params)
        render "show", status: :ok
      else
        render json: { :message => @current_api_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end
    
    def speed_test
      if params[:test_file].present?
        file_size = params[:test_file].length
        render json: { :message => "Speed test peformed on file of size #{number_to_human_size(file_size)}" }, status: :ok
      else
        render json: { :message => "Could not perform speed test, missing test file." }, status: :unprocessable_entity
      end
    end

    private

      def permitted_params
        the_params = []

        the_params.push(:username) if Rails.configuration.use_username
        the_params.push(:first_name) if Rails.configuration.use_first_name
        the_params.push(:last_name) if Rails.configuration.use_last_name
        the_params.push(:mobile_phone) if Rails.configuration.use_mobile_phone
        the_params.push(:avatar) if Rails.configuration.use_avatar

        if Rails.configuration.enable_location
          the_params.push(:longitude)
          the_params.push(:latitude)
        end

        params[:user].permit(the_params)
      end

  end
end
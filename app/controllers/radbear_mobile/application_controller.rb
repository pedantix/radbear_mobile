module RadbearMobile
  class ApplicationController < ActionController::Base
    protect_from_forgery
    prepend_before_action :get_auth_token
    before_action :set_api_version
    
    def current_auth_user
      return @current_api_user
    end
    
    private
    
      def rb_token_auth
        users = User.where("authentication_token = ?", params[:auth_token])
        if users.count != 1
          render :status => 401, :json => {:message => "You are not authorized for this operation"}
        else
          @current_api_user = users.first
          if (!@current_api_user.active_for_authentication?)
            render :status => 401, :json => {:message => t("devise.failure.#{@current_api_user.inactive_message}")}
          end
        end
      end
    
      def set_api_version
        path_items = controller_path.split("/")      
        @api_version = path_items[1]
      end
      
      def get_auth_token
        if auth_token = params[:auth_token].blank? && request.headers["HTTP_X_AUTH_TOKEN"]
          params[:auth_token] = auth_token
        end      
      end
  end
end

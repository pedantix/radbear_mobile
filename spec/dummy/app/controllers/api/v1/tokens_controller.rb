module Api
  module V1
    class TokensController < RadbearMobile::TokensController
      #override controller actions here as needed
      
      #def create
      #  super
      #  if @current_api_user
      #    do some more stuff
      #  end
      #end
      
      #to deprecate an api version with a warning message to the client to upgrade
      #override the create like this
      #def create
      #  @api_deprecated = true
      #  super
      #end
      
      #to remove an api version with a fatal message to the client to upgrade
      #override the create like this
      #def create
      #  @api_removed = true
      #  super
      #end
    end
  end
end
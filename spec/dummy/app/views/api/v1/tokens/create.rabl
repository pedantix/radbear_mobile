collection @users => :users

extends "api/#{@api_version}/users/attribs"

node(:api_message, :if => lambda { |this_user| @api_deprecated == true}) do
  "This version of the app will no longer be supported in the near future, please upgrade soon."
end
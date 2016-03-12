attributes :email, :id, :first_name, :last_name, :display_name, :mobile_phone, :username, :longitude, :latitude, :account_verified, :created_at, :admin

node(:is_me, :if => lambda { |this_user| this_user == @current_api_user }) do |this_user|
  true
end

node(:authentication_token, :if => lambda { |this_user| this_user == @current_api_user }) do |this_user|
  this_user.authentication_token
end

node(:avatar) do |this|
  if this.avatar.present?
    {:small => this.avatar.url(:small), :normal => this.avatar.url(:normal)}
  elsif this.provider_avatar
    {:small => this.provider_avatar, :normal => this.provider_avatar}
  else
    #todo asset_avatar("document.png")
  end
end
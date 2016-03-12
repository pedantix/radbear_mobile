Rails.application.config.assets.precompile += %w( radbear_rails/radbear_mailer.css )

Rails.configuration.enable_facebook = true
Rails.configuration.enable_twitter = false
Rails.configuration.use_avatar = false

Devise.setup do |config|
  config.mailer = 'RadbearDeviseMailer'
end
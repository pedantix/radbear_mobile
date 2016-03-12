ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require 'rspec/rails'
require 'factory_girl_rails'
require 'faker'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
    
  config.before(:each) do
    allow(Company).to receive_message_chain(:main, :name).and_return("ABC Company")
    allow(Company).to receive_message_chain(:main, :full_address).and_return("100 1st Street, Encinitas, CA 92024")
    allow(Company).to receive_message_chain(:main, :address_1).and_return("foo")
    allow(Company).to receive_message_chain(:main, :address_2).and_return("bar")
    allow(Company).to receive_message_chain(:main, :city).and_return("blah")
    allow(Company).to receive_message_chain(:main, :state).and_return("blah")
    allow(Company).to receive_message_chain(:main, :zipcode).and_return("blah")
    allow(Company).to receive_message_chain(:main, :phone_number).and_return("blah")
    allow(Company).to receive_message_chain(:main, :website).and_return("blah")
    allow(Company).to receive_message_chain(:main, :email).and_return("blah")
    allow(Company).to receive_message_chain(:main, :company_logo_includes_name).and_return(false)
    allow(Company).to receive_message_chain(:main, :app_logo_includes_name).and_return(false)
  end
  
  include Devise::TestHelpers
  include Warden::Test::Helpers
end

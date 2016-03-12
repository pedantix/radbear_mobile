module RadbearMobile
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "Used to install the radbear_mobile depencency files and create migrations."
      
      def create_initializer_file
        #initializers
        template "../../../../../spec/dummy/config/initializers/radbear_mobile.rb", "config/initializers/radbear_mobile.rb"
        template "../../../../../spec/dummy/config/initializers/rabl_init.rb", "config/initializers/rabl_init.rb"
        
        template "../../../../../spec/dummy/app/controllers/api/v1/app_settings_controller.rb", "app/controllers/api/v1/app_settings_controller.rb"
        template "../../../../../spec/dummy/app/controllers/api/v1/tokens_controller.rb", "app/controllers/api/v1/tokens_controller.rb"
        template "../../../../../spec/dummy/app/controllers/api/v1/users_controller.rb", "app/controllers/api/v1/users_controller.rb"
        template "../../../../../spec/dummy/app/controllers/api/v1/devices_controller.rb", "app/controllers/api/v1/devices_controller.rb"
        
        #models
        template "../../../../../spec/dummy/app/models/user.rb", "app/models/user.rb"
        template "../../../../../spec/dummy/app/models/concerns/token_authenticatable.rb", "app/models/concerns/token_authenticatable.rb" unless options.no_mobile_app
        
        #views
        template "../../../../../spec/dummy/app/views/api/v1/tokens/create.rabl", "app/views/api/v1/tokens/create.rabl"
        template "../../../../../spec/dummy/app/views/api/v1/users/_attribs.rabl", "app/views/api/v1/users/_attribs.rabl"
        template "../../../../../spec/dummy/app/views/api/v1/users/show.rabl", "app/views/api/v1/users/show.rabl"
        template "../../../../../spec/dummy/app/views/api/v1/users/index.rabl", "app/views/api/v1/users/index.rabl"

        #tests
        template "../../../../../spec/controllers/api/v1/tokens_controller_spec.rb", "spec/controllers/api/v1/tokens_controller_spec.rb"
        template "../../../../../spec/controllers/api/v1/users_controller_spec.rb", "spec/controllers/api/v1/users_controller_spec.rb"
        template "../../../../../spec/controllers/api/v1/app_settings_controller_spec.rb", "spec/controllers/api/v1/app_settings_controller_spec.rb"
        template "../../../../../spec/requests/users_spec.rb", "spec/requests/users_spec.rb"
        
        inject_into_file "config/routes.rb", after: "Application.routes.draw do" do <<-'RUBY'

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: RadbearMobile::ApiConstraints.new(version: 1) do
      resources :app_settings, :only => :index
      resources :tokens, :only => [:create, :destroy]
      resources :devices, :only => :create
      
      resources :users, :only => [:index, :update, :speed_test] do
        put :speed_test, :on => :collection
      end
    end
  end

        RUBY
        end
        
        apply_migration "../../../../../spec/dummy/db/migrate/20140302111111_add_radbear_mobile_fields.rb", "add_radbear_user_fields"
        apply_migration "../../../../../spec/dummy/db/migrate/20140603113006_add_platform_and_version_to_users.rb", "add_platform_and_version_to_users"
      end
      
      def self.next_migration_number(path)
        next_migration_number = current_migration_number(path) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end
      
      protected
      
        def apply_migration(source, filename)
          if self.class.migration_exists?("db/migrate", "#{filename}")
            say_status("skipped", "Migration #{filename}.rb already exists")
          else
            migration_template source, "db/migrate/#{filename}.rb"
          end
        end
      
    end
  end
end
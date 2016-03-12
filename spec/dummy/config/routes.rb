Rails.application.routes.draw do    
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
  
  devise_for :users
end
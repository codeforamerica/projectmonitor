ProjectMonitor::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :sessions => "sessions" }
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  get 'builds' => "home#builds", format: :rss
  get 'version' => 'versions#show'

  post 'projects/validate_build_info'

  resource :configuration, only: [:show, :create, :edit], controller: "configuration"
  resources :users, :only => [:new, :create]
  resources :projects do
    resources :payload_log_entries, only: :index
    resource :status, only: :create, controller: "status"
    member do
      get :status
    end
  end
  resources :messages, only: [:index, :new, :create, :edit, :update, :destroy] do
    get :load_message
  end

  authenticate :user do
    get "/jobs" => DelayedJobWeb, :anchor => false
  end

  root :to => 'home#index'
end

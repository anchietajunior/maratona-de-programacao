Rails.application.routes.draw do
  resource :session
  resource :scoreboard, only: :show
  resource :standings, only: :show

  resources :problems, only: %i[ index show ] do
    resources :submissions, only: :create
    resources :clarifications, only: :create
  end

  resources :clarifications, only: :index

  namespace :staff do
    root "dashboards#show"

    resource :start, only: %i[ create destroy ]
    resource :closure, only: :create
    resource :publication, only: %i[ create destroy ]
    resource :standings, only: :show

    resources :problems do
      resources :testcases, only: %i[ create destroy ]
    end

    resources :submissions, only: :index
    resources :clarifications, only: :index do
      resource :answer, only: :create
    end

    resources :balloons, only: :index
    resources :deliveries, only: %i[ create destroy ]
    resources :sessions, only: :destroy
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in config/routes.rb too!)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#show"
end

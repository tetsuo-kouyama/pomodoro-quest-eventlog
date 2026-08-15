Rails.application.routes.draw do
  root "static_pages#top"

  resources :users, only: %i[ new create ]

  resources :owned_monsters, only: %i[ index new create show destroy ] do
    member do
      post :levelup
    end
  end

  resources :adventures, only: %i[ index new create show ] do
    resources :adventure_events, only: :index
    member do
      patch :claim
      get :events
    end
  end

  resource :party, only: %i[ show edit ] do
    member do
      patch :add_monster
      patch :remove_monster
    end
  end

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end

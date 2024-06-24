Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
    registrations: "users/registrations",
    confirmations: "users/confirmations",
  }

  resources :attendances, only: [:index, :new] do
    collection do
      get ":date", to: "attendances#show", as: "date"
      post "clock_in/:date", to: "attendances#clock_in", as: "clock_in"
      post "clock_out/:date", to: "attendances#clock_out", as: "clock_out"
    end
  end

  get "mypage", to: "users#show", as: "mypage"

  devise_for :admins, controllers: {
    sessions: "admins/sessions",
  }

  namespace :admins do
    root to: "dashboard#index"
    resources :users, only: [:index, :edit, :update, :destroy]
    resources :special_days, only: [:index, :new, :create, :destroy]
  end

  root to: "attendances#index"

  get "/403", to: "errors#forbidden"
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unprocessable_entity"
  get "/500", to: "errors#internal_server_error"

  match "*path", to: "errors#not_found", via: :all
end

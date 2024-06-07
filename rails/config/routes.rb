Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
    registrations: "users/registrations",
    confirmations: "users/confirmations",
  }

  get "mypage", to: "users#show", as: "mypage"

  devise_for :admins, controllers: {
    sessions: "admins/sessions",
  }

  namespace :admins do
    root to: "dashboard#index"
    resources :users
  end

  root "calendars#index"
end

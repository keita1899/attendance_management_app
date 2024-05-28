Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
    registrations: "users/registrations",
    confirmations: "users/confirmations",
  }

  devise_for :admins, controllers: {
    sessions: "admins/sessions",
  }

  namespace :admins do
    resources :dashboard, only: [:index]
    root to: "dashboard#index"
  end

  root "calendars#index"
end

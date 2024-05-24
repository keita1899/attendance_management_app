Rails.application.routes.draw do
  root "calendars#index"
  devise_for :users, controllers: { registrations: "users/registrations" }
end

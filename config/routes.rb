Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root to: "pages#home"
  get "privacy", to: "pages#privacy"

  resources :add_ons, only: [:index, :destroy]

  resources :conversions, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :syncs, only: [:create, :edit, :update]
  end

  resources :oauth, only: [:index, :new]
end

Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :conversions, only: [:index, :new, :create, :destroy] do
    resources :syncs, only: [:new, :create]
  end

  resources :oauth, only: [:index, :new]
end

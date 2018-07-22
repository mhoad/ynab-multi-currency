Rails.application.routes.draw do
  root to: "pages#home"

  resources :conversions, only: [:index, :new, :create] do
    resources :syncs, only: [:new, :create]
  end
end

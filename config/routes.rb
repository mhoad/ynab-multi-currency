Rails.application.routes.draw do
  resources :conversions, only: [:index, :new, :create] do
    resources :syncs, only: [:new, :create]
  end
end

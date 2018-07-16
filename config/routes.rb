Rails.application.routes.draw do
  resources :conversions, only: [:index, :new, :create]
end

p 'hi'
WatCatcher::Rails::Engine.routes.draw do
  resources :client_wats, only: :create
end
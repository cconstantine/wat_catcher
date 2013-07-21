WatCatcher::Engine.routes.draw do
  resources :wats, only: :create, module: "wat_catcher"
end

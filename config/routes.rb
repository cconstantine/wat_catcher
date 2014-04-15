WatCatcher::Engine.routes.draw do
  scope module: 'wat_catcher' do
    resources :wats, only: :create
    resources :bugsnag, only: :show
  end
end

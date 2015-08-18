Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'registrations'}

  get '/c/:code' => 'visitors#coupon'
  get '/descuentosorteo' => 'payments#descuentosorteo'

  devise_scope :user do
    get '/cuenta' => 'registrations#edit', as: :account
    get '/logout' => 'devise/sessions#destroy', as: :logout
  end

  match '/consentimiento' => 'visitors#consentimiento', as: 'consentimiento_informado', via: [:get, :post]
  get '/informacion-comienzo' => 'visitors#informacion_comienzo', as: 'informacion_comienzo'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'visitors#index'
  resources :users, :payments
  resources :messages, path: 'mensajes' do
    put :move
  end
  resources :folders, only: [:create] do
    resources :messages, only: [:index]
  end
end

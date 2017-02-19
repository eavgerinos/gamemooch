Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks", :registrations => "registrations" }
  get 'welcome/index'
  get 'igdb/search'
  get 'igdb/games'
  get 'users/games'

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :games
end

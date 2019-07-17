Rails.application.routes.draw do
  root 'static_page#home'

  match '/signup', to: 'users#new', via: 'get'
  match '/help', to: 'static_page#help', via: 'get'
  match '/home', to: 'static_page#home', via: 'get'
  match '/about', to: 'static_page#about', via: 'get'
  match '/contact', to: 'static_page#contact', via: 'get'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'DELETE'

  resources :microposts, only: %i[new create destroy]
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :sessions, only: %i[new create destroy]
  resources :relationships, only: %i[create destroy]
end

# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/edit_password'
  get 'users/update_password'
  get 'about' => 'site#about', as: :about
  resources :profiles
  resources :items do
    get '/read' => 'items#read', as: :read
    get '/seen' => 'items#seen', as: :seen
  end
  get '/feeds/fetch' => 'feeds#fetch'
  resources :feeds, only: %(show)

  get 'user/password' => 'users#edit_password', as: :change_password
  patch 'user/update_password' => 'users#update_password', as: :update_password
  devise_for :users

  authenticated :user do
    root to: 'profiles#default', as: :authenticated_root
  end

  unauthenticated :user do
    root 'items#index'
  end
end

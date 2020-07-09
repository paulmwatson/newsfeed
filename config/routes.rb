# frozen_string_literal: true

Rails.application.routes.draw do
  get 'about' => 'site#about', as: :about
  resources :profiles
  resources :items do
    get '/read' => 'items#read', as: :read
    get '/seen' => 'items#seen', as: :seen
  end
  resources :feeds, only: %(show)
  devise_for :users

  authenticated :user do
    root to: 'profiles#default', as: :authenticated_root
  end

  unauthenticated :user do
    root 'items#index'
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  resources :profiles
  resources :items do
    get '/read' => 'items#read', as: :read
    get '/seen' => 'items#seen', as: :seen
  end
  resources :feeds
  devise_for :users

  authenticated :user do
    root to: 'profiles#default', as: :authenticated_root
  end

  unauthenticated :user do
    root 'items#index'
  end
end

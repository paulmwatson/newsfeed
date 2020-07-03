# frozen_string_literal: true

Rails.application.routes.draw do
  resources :profiles
  resources :items
  resources :feeds
  devise_for :users
  root 'items#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

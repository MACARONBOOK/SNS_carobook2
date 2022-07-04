Rails.application.routes.draw do
  devise_for :users

  root to: "homes#top"
  get "home/about"=>"homes#about"

  resources :books, only: [:index,:show,:edit,:create,:destroy,:update] do
    resources :book_comments, only: [:create, :destroy]
    resource :favorites, only: [:create, :destroy]
  end
  resources :users, only: [:index,:show,:edit,:update] do
    resource :relationships, only: [:create, :destroy]
  	get 'followings' => 'relationships#followings', as: 'followings'
  	get 'followers' => 'relationships#followers', as: 'followers'
  end

  post '/books/:book_id/favorites' => 'favorites#create', as: 'create_favorites'
  delete '/books/:book_id/favorites' => 'favorites#destroy', as: 'destroy_favorites'

  get '/search', to: 'searches#search'
end

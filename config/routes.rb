Rails.application.routes.draw do
  devise_for :users

  root to: "homes#top"
  get '/home/about' => 'homes#about', as:'about'

  resources :users, only: [:index,:show,:edit,:update]
  resources :books, only: [:index,:show,:edit,:create,:destroy,:update] do
    resources :book_comments, only: [:create, :destroy]
  # resource :favorites, only: [:create, :destroy]
  end

  post '/books/:book_id/favorites' => 'favorites#create', as: 'create_favorites'
  delete '/books/:book_id/favorites' => 'favorites#destroy', as: 'destroy_favorites'

end

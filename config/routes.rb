Rails.application.routes.draw do
  root 'users#new'
  post '/callback' => 'linebot#callback'
  resources :users, only: %i(new create show index)
end

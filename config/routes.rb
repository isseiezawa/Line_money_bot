Rails.application.routes.draw do
  root 'moneys#new'
  post '/callback' => 'linebot#callback'
  resources :moneys, only: %i(index create)
end

Rails.application.routes.draw do
  get "home/index"
  resources :books

  devise_for :users

  namespace :api do
    get "books/search" => "books#search", defaults: { format: :json } #Quando o usuário acessar a rota /books/search, a requisição será direcionada para a ação search do Api::BooksController
  end 

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end

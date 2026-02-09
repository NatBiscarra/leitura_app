class Api::BooksController < ApplicationController #Criação do controller para a API
  before_action :authenticate_user! #Garante que apenas usuario autenticado possa acessar a ação de busca

  def search
    results = OpenLibraryService.search(params[:title]) #Chama o service passando o título recebido como parâmetro e armazena os resultados
    render json: results
  end
end

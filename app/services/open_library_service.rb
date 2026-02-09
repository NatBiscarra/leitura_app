require "net/http"  #Importar bibliotecas para requisições HTTP e manipulação de JSON
require "json"

class OpenLibraryService
  BASE_URL = "https://openlibrary.org/search.json"

  def self.search(title)  
    url = URI("#{BASE_URL}?title=#{URI.encode_www_form_component(title)}") #Construir a URL de busca (URL + titulo + texto digitado pelo usuario)

    response = Net::HTTP.get(url)  #Fazer a requisição GET para a API
    data = JSON.parse(response) #Converter o JSON em um objeto Ruby

    data["docs"].first(5).map do |book|  #Retornar os primeiros 5 resultados com titulo, autor e ano de publicação
      {
        title: book["title"],
        author: book["author_name"]&.first,
        year: book["first_publish_year"]
      }
    end
  end
end

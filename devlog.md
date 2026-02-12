 
## Dia 1 — Configuração do ambiente e infraestrutura do projeto

No primeiro dia, o foco foi estruturar todo o ambiente de desenvolvimento e preparar a base da aplicação, garantindo que o projeto pudesse ser executado tanto localmente quanto em containers Docker, simulando um cenário próximo ao de produção.

Inicialmente, configurei o ambiente utilizando **WSL (Ubuntu)** no Windows, permitindo trabalhar em um sistema Linux real. Essa escolha foi importante para garantir maior compatibilidade com **Ruby on Rails, Docker e ferramentas de backend**, além de reproduzir melhor o ambiente normalmente utilizado em servidores de produção.

Em seguida, verifiquei e instalei as principais dependências do projeto: **Ruby, Rails, Git, Docker e Docker Compose**. 

Com o ambiente configurado, criei o projeto Rails utilizando o comando:
```
rails new leitura_app -d sqlite3
```

Isso gerou a estrutura base do framework (MVC, configurações, banco de dados e dependências). Após a criação, testei a aplicação localmente executando:
```
rails db:create
rails s
```
e confirmei o funcionamento acessando **[http://localhost:3000](http://localhost:3000)** no navegador.

Depois de validar que o projeto rodava corretamente, realizei o **commit inicial no Git**, contendo apenas o código gerado automaticamente pelo `rails new`, conforme solicitado nas instruções do teste. Também foi necessário configurar a integração do Git dentro do WSL para versionar o código corretamente.

Na sequência, iniciei a **dockerização do projeto**. Criei o `docker-compose.yml` para orquestrar os containers e utilizei o `Dockerfile` para definir o ambiente necessário para rodar a aplicação (imagem Ruby, dependências, gems e comando de execução). 
Durante esse processo, identifiquei que o Dockerfile gerado por padrão era voltado para produção, o que dificultava o uso em desenvolvimento. Por isso, adaptei o arquivo para um modo **development**, simplificando configurações, removendo otimizações de produção e ajustando a execução do servidor Rails.

Por fim, fiz o **build da imagem e subi o container**, confirmando que a aplicação também rodava corretamente via Docker. As configurações de Docker foram então versionadas em um novo commit.

## Dia 2 - Desenvolvimento CRUD

Foquei principalmente em implementar a autenticação de usuários e em estruturar o CRUD de livros, conectando cada livro a um usuário logado e adicionando regras de segurança para controle de acesso às ações com livros.

Comecei integrando o Devise. Ele facilita a criação de funcionalidades como cadastro, login, logout, etc, evitando que eu precise implementar toda essa lógica manualmente.

Antes de usar essa gem, pesquisei como esse processo seria feito “na mão” (criando rotas, controllers, sessões, etc.), para entender melhor o que o Devise automatiza.

Primeiro adicionei a gem ao projeto
```
bundle add devise
```

Em seguida, executei o comando que criou os arquivos de configuração (config/initializers/devise.rb)
```
rails generate devise:install
```
 
 Depois, rodei o comando 
 ```
 rails generate devise User
 ```
 que gerou automaticamente o model user (app/models/user.rb) (classe com métodos), a migration (db/migrate/xxxxxx_devise_create_users.rb) para criar a tabela users no banco de dados e as rotas (config/routes.rb) de autenticação através de `devise_for :users`.
	 obs: `devise_for :users`  gera todas as rotas de login, logout, cadastro, editar conta, resetar senha...
Após, rodei o servidor local para verificar se estavam funcionando. 

Ou seja, após executar `rails db:migrate`, a tabela de usuários foi criada com campos como `email`, `encrypted_password` e tokens de recuperação de senha. Ao iniciar o servidor com `rails s`, já passei a ter páginas funcionais de cadastro, login e logout.


Na segunda parte do dia, utilizei o **scaffold do Rails** para gerar rapidamente um CRUD completo de livros. Com o comando  
```
rails g scaffold Book title:string author:string year:integer user:references  
```
o Rails criou automaticamente o model, a migration, o controller, as views e as rotas do recurso `Book`.
Book é o nome do model criado, então o rails cria automaticamente a tabela books, o controller BooksController, rotas /books.

A migration criou a tabela `books` com os campos definidos e também a coluna `user_id` por meio de `user:references`, estabelecendo o relacionamento com o usuário (ou seja, User (Devise) + Book). As views já vieram prontas (index, show, new, edit e form), o que me permitiu testar o CRUD imediatamente após rodar
```
rails db:migrate
```
e acessar `/books` no navegador.

Obs: No bash title:string author:string year:integer user:references vira no banco em Ruby 
	t.string :title 
	t.string :author
	t.integer :year
	t.references :user  (isso aqui cria um relacionamento no banco de dados, já que cada book pertence a um user)

Depois disso, configurei explicitamente a associação entre os models. No `book.rb` (app/models/book.rb), o `belongs_to :user` já havia sido criado automaticamente pelo scaffold. Já no `user.rb` (app/models/user.rb), precisei adicionar manualmente `has_many :books, dependent: :destroy`, indicando que um usuário pode ter vários livros e que, caso ele seja removido, todos os seus livros também serão excluídos. Isso garante a integridade dos dados.

Em seguida, implementei uma regra de segurança para que apenas usuários autenticados possam acessar as ações relacionadas aos livros. Para isso, adicionei `before_action :authenticate_user!` no topo do `BooksController` (app/controllers/books_controller.rb). Esse método do Devise bloqueia o acesso de visitantes não logados e redireciona para a página de login.

Por fim, comecei a preparar a lógica para garantir que cada usuário visualize e manipule apenas os **seus próprios livros**, reforçando o controle de acesso e a segurança da aplicação.

No método create (em books_controller), alterei @book = Book.new(book_params) por  
```
@book = current_user.books.build(book_params)
```

em index, @books = Book.all por
```
@books = current_user.books
```

em edição/deleção adicionei 
```
before_action :authorize_user!, only: %i[ edit update destroy ]
```

e criei o método authorize_user!
```
def authorize_user!
  redirect_to books_path, alert: "Not allowed" unless @book.user == current_user
end
```

Ao final do dia, consegui deixar o sistema com:
- autenticação completa com Devise    
- cadastro e login funcionando    
- CRUD de livros gerado automaticamente com scaffold    
- associação 1:N entre usuários e livros    
- rotas protegidas exigindo login    
- base pronta para controle de propriedade dos dados

Portanto, a aplicação funcionava normalmente quando eu iniciava o servidor localmente com `rails s`, mas não rodava corretamente dentro do container Docker. Puder verificar, pelas mensagens de erro, que o problema estava na parte de banco de dados e migrations. 

## Dia 3 - Correção de problemas (migration)

Primeiro, verifiquei se o container estava ativo utilizando o comando 
```
docker compose ps
```
que lista os containers em execução e suas portas. Em seguida, subi a aplicação com 
```
docker compose up
```
o que inicializou o serviço web dentro do Docker. Até esse momento, o servidor parecia estar rodando, mas a aplicação ainda não funcionava como esperado.

Para confirmar essa hipótese, executei 
```
docker compose exec web rails db:migrate:status
```
para verificar o status das migrations no ambiente do Docker. Recebi a mensagem “Schema migrations table does not exist yet”, o que mostrou que o banco de dados ainda nem havia sido criado. Ou seja, o banco que eu utilizava localmente ainda não estava compartilhado com o container. Mesmo que as migrations já tivessem sido rodadas na minha máquina, dentro do docker tudo começava do zero.

Precisei preparar o banco manualmente dentro do container. Executei 
```
docker compose exec web rails db:create
```
para criar o banco e depois 
```
docker compose exec web rails db:migrate
```
para rodar as migrations. Verificando novamente com `rails db:migrate:status`, todas apareceram como “up”, confirmando que as tabelas tinham sido criadas corretamente. Depois disso, ao acessar o navegador, a aplicação finalmente funcionou também no Docker.

Apesar de resolver o problema manualmente, percebi que esse processo seria repetitivo e pouco prático, já que sempre que um container novo fosse criado eu teria que rodar esses comandos novamente. Pesquisando uma alternativa, descobri o comando `rails db:prepare`, que automatiza a criação do banco e a execução das migrations em uma única etapa. Achei mais eficiente integrar isso diretamente na inicialização do container.

Então editei o `docker-compose.yml` e alterei o comando de inicialização do serviço para incluir o `rails db:prepare` antes de subir o servidor. 
```
command: bash -c "rm -f tmp/pids/server.pid && rails db:prepare && rails s -b 0.0.0.0"
```
O comando ficou responsável por preparar o banco automaticamente e só depois iniciar o Rails. Dessa forma, sempre que executo `docker-compose up`, todo o ambiente já sobe configurado, sem necessidade de fazer manualmente.

## Dia 4 - Integração com API externa (OpenLibrary)

Objetivo: criar um fluxo claro em que o controller recebe a requisição do navegador, chama um service responsável pela integração externa, recebe os dados tratados em JSON e devolve a resposta ao usuário.

Comecei criando a pasta app/services, é importante para manter o código organizado. Entendi que nem toda lógica pertence a models ou controllers, principalmente quando se trata de integrações com APIs externas. Para isso, criei a estrutura com `mkdir app/services` e o arquivo `open_library_service.rb`.

Implementei o **service object**, responsável por fazer a chamada HTTP para a OpenLibrary. 
(Estrutura semelhante ao que aprendi em Java). Dentro dele utilizei `require` para importar as bibliotecas `net/http` e `json`. Criei a classe `OpenLibraryService`, defini uma constante `BASE_URL` com o endereço da API e escrevi o método de busca que monta a URL, faz a requisição, converte o JSON recebido e devolve apenas os campos que interessam (título, autor e ano). Assim, o service já entrega os dados prontos e “limpos”, sem expôr o restante da estrutura da API para o restante do sistema.

Criei o **controller da API** `app/controllers/api/books_controller.rb`, pois entendi que o service sozinho não consegue “conversar” com o navegador.
O controller é a ponte entre o navegador e o service, recebendo a requisição HTTP, chamando a lógica de busca (uso do método definido do service) e retornando os resultados em JSON. 
Sem controller não existe rota nem endpoint acessível externamente. 

Depois disso, criei a **rota no `routes.rb`**, adicionando `get "books/search", to: "books#search"` dentro do namespace `api`, para que o caminho `/api/books/search` seja direcionado para o método `search` do `Api::BooksController`. Com isso, a aplicação passou a ter um endpoint acessível via HTTP.

Por fim, subi o ambiente com `docker-compose up` e testei no navegador acessando 
```
http://localhost:3000/api/books/search?title=test
```
A requisição funcionou corretamente e retornou o JSON com os livros encontrados.

### Implementar busca de livro (integrar front com API)
Adicionei o formulário de busca na view `books/index.html.erb`, com campo de texto, botão de busca e uma área para exibir os resultados. Criei o arquivo `app/javascript/books_search.js` (implementação da lógica para capturar o clique no botão, enviar uma requisição fetch para o endpoint `/api/books/search`, renderizar os livros retornados na tela e permitir salvar cada livro no banco via requisição POST para `/books` (buscar na OpenLibrary → exibir resultados → salvar → recarregar a página com o livro listado).

Durante os testes o botão “buscar” não executava nenhuma ação. Pelo console do navegador identifiquei um erro 404 relacionado ao carregamento do arquivo `books_search.js`, indicando que o js não estava sendo encontrado nos assets. A partir disso, comecei a depurar a configuração do Importmap. Revisei e alterei o `application.js` (ajustando os imports), o `importmap.rb` (tentando adicionar/remover pins), o `index.html.erb` e o próprio `books_search.js`, além de reiniciar o Docker várias vezes. Mesmo assim, o erro 404 persistiu, impedindo a execução do JavaScript e, consequentemente, a funcionalidade de busca na interface. Portanto, a estrutura já está implementada, mas o problema de carregamento do asset ainda não foi solucionado.

## Dia 5 - Erro de carregamento do Js e implementação da interface

### Correção de erro 
Depois de ajustar o import no `books_search.js` e adicionar o `pin` correspondente no `importmap.rb`, um novo aviso passou a aparecer relacionado ao preload do arquivo de estilos (`application.css`). O navegador indicava que o recurso havia sido pré-carregado, mas não estava sendo utilizado, o que sugeria um problema de referência no layout principal. 
Utilizando o Copilot, verifiquei que o `application.html.erb` estava apontando para um arquivo inexistente chamado `:app` em vez do padrão `"application"`. Essa configuração incorreta fazia com que o CSS fosse baixado, mas não aplicado, podendo impactar também o carregamento correto dos scripts subsequentes.

A solução sugerida foi corrigir a referência no `stylesheet_link_tag`, substituindo `:app` por `"application"`, garantindo que o Rails vinculasse o arquivo `application.css` correto. Após essa sincronização entre o layout e os assets, a aplicação voltou a funcionar normalmente. 
Assim, já conseguia realizar busca de livros, salvar e visualizar na lista, confirmando que tanto o JavaScript quanto a integração com o banco de dados estavam operando corretamente.

### Interface com Bootstrap
O primeiro passo foi adicionar o Bootstrap ao importmap por meio dos comandos `bin/importmap pin bootstrap` e `bin/importmap pin @popperjs/core`, que registraram as dependências no arquivo `config/importmap.rb` (os pins permitem que o rails reconheça e carregue os módulos JavaScript diretamente no navegador). 
Depois realizei a importação global no arquivo `app/javascript/application.js`, adicionando `import "bootstrap"`, para que os componentes interativos funcionassem em toda a aplicação.

Como o importmap gerencia apenas JavaScript, a inclusão do CSS do bootstrap precisou ser feita separadamente, adicionando o link de estilos manualmente para que a estilização fosse aplicada corretamente. Durante essa etapa, enfrentei um erro 404 no console relacionado ao carregamento do `@popperjs/core`. O problema estava no caminho gerado automaticamente pelo pin, que não correspondia a um arquivo válido. Para resolver, o copilot ajustou o pin para apontar diretamente para a URL do jsDelivr. Isso garantiu o carregamento correto da dependência e restaurou o funcionamento dos componentes que dependem do Popper.
```
 pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/esm/index.js"
```

Com essas configurações concluídas, o bootstrap passou a funcionar corretamente no projeto.

### Separação de parte pública e privada 
Objetivo: Reorganizar a estrutura da aplicação para separar a parte pública da parte privada do projeto. Diferenciar o que pode ser acessado por qualquer visitante (visualizar todos os livros já cadastrado) do que deve ficar restrito ao usuário autenticado, como a busca e gerenciamento da lista de “meus livros”.

Organizei a aplicação separando melhor as funcionalidades públicas das privadas por meio de ajustes no arquivo **`config/routes.rb`**. Mantive **`resources :books`** para as ações relacionadas aos livros salvos no banco (listar, adicionar e remover), caracterizando a área privada do usuário, enquanto a busca foi isolada em um **namespace `api`**, criando o endpoint **`/api/books/search`**, atendido pelo **`Api::BooksController#search`** e retornando dados em JSON para consumo via JavaScript. 

Também atualizei as chamadas no **`app/javascript/books_search.js`** e nos links das views para utilizar os novos caminhos, o que eliminou erros de rota e deixou a estrutura mais clara, separando corretamente a visualização pública do gerenciamento privado dos livros.

Finalizei o dia ajustando o layout da aplicação para atender aos requisitos do desafio. No arquivo **`app/views/layouts/application.html.erb`**, estruturei o cabeçalho com Bootstrap para criar uma barra de navegação mais clara e funcional. Adicionei botões de **Login** e **Criar conta** quando o usuário não está autenticado.
Implementei a renderização condicional com helpers do **Devise**, exibindo o nome do usuário logado e a opção de sair quando autenticado. 
Isso garantiu uma separação visual entre estados público e privado.
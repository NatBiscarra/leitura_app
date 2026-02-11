# Leitura App

Aplicação web desenvolvida em Ruby on Rails para cadastro e visualização de livros, com autenticação de usuários e integração com a API OpenLibrary.

Este projeto foi desenvolvido como parte do Desafio Técnico de Estágio da Mconf.

---
## Como rodar o projeto 
### Pré-requisitos
* Docker
* Docker Compose

### Passos
1. Clonar este repositório em sua máquina
   ```
   git clone https://github.com/NatBiscarra/leitura_app.git
   ```
2. Acessar o diretório
   ```
   cd leitura_app
   ```
3. Subir aplicação
   ```
   docker compose up --build
   ```
A aplicação ficará disponível em:
```
http://localhost:3000
```
#### Observação — o container executa automaticamente: 
* bundle install
* rails db:create
* rails db:migrate
* rails s
---
## Funcionalidades implementadas
### Área Pública
* Listagem de todos os livros cadastrados por todos os usuários
* Navbar com **Login** e **Criar conta**

### Área autenticada
Usuário logados pode:
* Cadastrar livros
* Buscar livros pelo título (OpenLibrary)
* Salvar livros no banco
* Editar livros próprios
* Remover livros próprios
* Visualizar apenas seus livros em **Meus livros**

### Fluxo de cadastro (integrado com API)
* Usuário digita o título
* Backend consulta a OpenLibrary API
* Rails retorna JSON
* JavaScript exibe os resultados
* Usuário clica em **Salvar**
* Livro é persistido no banco

---
## Tecnologias utilizadas
* Ruby on Rails
* SQLite3
* Devise (autenticação)
* JavaScript (fetch API)
* Bootstrap (interface)
* Docker + Docker Compose
* HTTParty (requisições HTTP para API externa)
* Importmap
---
## Uso de IA
Durante o desenvolvimento do projeto, utilizei IA (ChatGPT) como ferramenta de apoio para elaboração de um plano de trabalho, esclarecer conceitos técnicos (como funcionamento de Docker e volumes, execução de migrations dentro de containers, organização MVC no Rails), sugerir estrutura de código e auxiliar na resolução de erros.

Ao longo do desenvolvimento, alguns problemas surgiram devido a soluções incompletas ou superficiais sugeridas pela IA, principalmente relacionados ao ambiente Docker, banco de dados SQLite e execução de migrations dentro do container. Nesses casos, investiguei os erros, consultei a documentação e materiais disponíveis na internet para realizar os ajustes.

Exemplos:
* Persistência do banco no Docker: inicialmente foi sugerido apenas rodar migrations manualmente, porém o banco não persistia ao reiniciar o container. Ajustei o docker-compose.yml para utilizar volumes e automatizar rails db:create db:migrate.
* Rotas da API redirecionando para login: o endpoint de busca da OpenLibrary estava protegido pelo Devise. Corrigi adicionando skip_before_action :authenticate_user! na API.
* Bootstrap: a configuração via importmap não carregava corretamente no ambiente Docker. Optei por utilizar CDN para garantir estabilidade.

O GitHub Copilot foi utilizado como ferramenta de apoio para debug, auxiliando na identificação de erros e sugerindo correções de código, que foram sempre revisadas e validadas manualmente.

---


  

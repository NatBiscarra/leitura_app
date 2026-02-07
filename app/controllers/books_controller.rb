class BooksController < ApplicationController
  before_action :authenticate_user! #Garante que o usuario esteja autenticado antes de acessar as ações
  before_action :set_book, only: %i[ show edit update destroy ]
  before_action :authorize_user!, only: %i[ edit update destroy ]


  # GET /books or /books.json
  def index
    @books = current_user.books #Exibe apenas os livros associados ao usuario atual
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = current_user.books.build(book_params)  #Associa o livro ao usuario atual

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Livro cadastrado com sucesso." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Livro atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!

    respond_to do |format|
      format.html { redirect_to books_path, notice: "Livro removido com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def authorize_user!
    redirect_to books_path, alert: "Você não está autorizado a realizar essa ação." unless @book.user == current_user
  end

  private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.expect(book: [ :title, :author, :year, :user_id ])
    end
end

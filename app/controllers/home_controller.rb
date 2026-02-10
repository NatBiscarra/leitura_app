class HomeController < ApplicationController
  #skip_before_action :authenticate_user!

  def index
    @books = Book.includes(:user).order(created_at: :desc)
  end
end

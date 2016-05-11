# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START index]
class BooksController < ApplicationController

  PER_PAGE = 10

  def index
    page_number = params[:page] ? params[:page].to_i : 1
    book_offset = PER_PAGE * (page_number - 1)
    @books      = Book.limit(PER_PAGE).offset(book_offset)
    @next_page  = page_number + 1 if @books.count == PER_PAGE
  end
# [END index]

  # [START new_and_edit]
  def new
    @book = Book.new
  end

  def edit
    @book = Book.find params[:id]
  end
  # [END new_and_edit]

  # [START show]
  def show
    @book = Book.find params[:id]
  end
  # [END show]

  # [START destroy]
  def destroy
    @book = Book.find params[:id]
    @book.destroy
    redirect_to books_path
  end
  # [END destroy]

  # [START update]
  def update
    @book = Book.find params[:id]

    if @book.update book_params
      flash[:success] = "Updated Book"
      redirect_to book_path(@book)
    else
      render :edit
    end
  end
  # [END update]

  # [START create]
  def create
    @book = Book.new book_params

    if @book.save
      flash[:success] = "Added Book"
      redirect_to book_path(@book)
    else
      render :new
    end
  end

  private

  def book_params
    params.require(:book).permit :title, :author, :published_on, :description,
                                 :cover_image
  end
  # [END create]
end

# Use DatastoreBooksController if database backend is configured for Datatore
if Rails.application.config.x.database.datastore?
  BooksController = DatastoreBooksController
end

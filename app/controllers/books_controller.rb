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

class BooksController < ApplicationController

  PER_PAGE = 10

  def index
    page = params[:page] ? params[:page].to_i : 0

    @books = Book.limit(PER_PAGE).offset(PER_PAGE * page)
    @next_page = page + 1 if @books.count == PER_PAGE
  end

  def new
    @book = Book.new
  end

  def create
    bp = upload_image(book_params)

    @book = Book.new bp

    if @book.save
      flash[:success] = "Added Book"
      redirect_to book_path(@book)
    else
      render :new
    end
  end

  def show
    @book = Book.find params[:id]
  end

  def edit
    @book = Book.find params[:id]
  end

  def update
    @book = Book.find params[:id]
    bp = upload_image(book_params)

    if @book.update bp
      flash[:success] = "Updated Book"
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  def destroy
    @book = Book.find params[:id]
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :published_on, :description, :photo)
  end

  #[START upload]
  def upload_image(book_params)
    storage = Fog::Storage.new provider: "Google"
    bp = book_params.clone
    unless bp['photo'].nil?
      bucket = storage.directories.get(Rails.configuration.x.fog_dir)
      rand = SecureRandom.hex
      image = bucket.files.new(
                               :key    => rand + bp['photo'].original_filename,
                               :body   => bp['photo'].read,
                               :public => true
                               )
      image.save
      bp['image_url'] = image.public_url
      bp.delete('photo')
    end
    bp
  end
  #[END upload]

end

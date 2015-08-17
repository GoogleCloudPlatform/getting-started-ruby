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

require "spec_helper"

feature "Managing Books" do

  before do
    allow_any_instance_of(LookupBookDetailsJob).to receive(:perform)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: :google_oauth2,
      uid: "123456",
      info: { name: "Fake User", image: "https://user-profile/image.png" }
    )
  end

  scenario "No books have been added" do
    visit root_path

    expect(page).to have_content "No books found"
  end

  scenario "Listing all books" do
    Book.create! title: "A Tale of Two Cities", author: "Charles Dickens"

    visit root_path

    expect(page).to have_content "A Tale of Two Cities"
    expect(page).to have_content "Charles Dickens"
  end

  scenario "Listing user's books" do
    Book.create! title: "Book created by anonymous user"
    Book.create! creator_id: "123456", title: "Book created by logged in user"

    visit root_path
    expect(page).not_to have_link "Mine"
    expect(page).to have_content "Book created by anonymous user"
    expect(page).to have_content "Book created by logged in user"

    click_link "Login"
    expect(page).to have_link "Mine"
    expect(page).to have_content "Book created by anonymous user"
    expect(page).to have_content "Book created by logged in user"

    click_link "Mine"
    expect(page).not_to have_content "Book created by anonymous user"
    expect(page).to have_content "Book created by logged in user"
  end

  scenario "Listing book cover images" do
    book = Book.create! title: "A Tale of Two Cities",
                        cover_image: Rack::Test::UploadedFile.new("spec/resources/test.txt")

    visit root_path

    expect(page).to have_content "A Tale of Two Cities"
    expect(page).to have_css "img[src='#{book.image_url}']"
  end

  scenario "Paginating through list of books" do
    Book.create! title: "Book 1"
    Book.create! title: "Book 2"
    Book.create! title: "Book 3"
    Book.create! title: "Book 4"
    Book.create! title: "Book 5"

    stub_const "BooksController::PER_PAGE", 2

    visit root_path
    expect(page).to have_content "Book 1"
    expect(page).to have_content "Book 2"
    expect(page).not_to have_content "Book 3"
    expect(page).not_to have_content "Book 4"
    expect(page).not_to have_content "Book 5"

    click_link "More"
    expect(page).not_to have_content "Book 1"
    expect(page).not_to have_content "Book 2"
    expect(page).to have_content "Book 3"
    expect(page).to have_content "Book 4"
    expect(page).not_to have_content "Book 5"

    click_link "More"
    expect(page).not_to have_content "Book 1"
    expect(page).not_to have_content "Book 2"
    expect(page).not_to have_content "Book 3"
    expect(page).not_to have_content "Book 4"
    expect(page).to have_content "Book 5"

    expect(page).not_to have_link "More"
  end

  scenario "Displaying a book" do
    Book.create! title: "A Tale of Two Cities",
                 author: "Charles Dickens",
                 published_on: "2015-01-01",
                 description: "This is a book!"

    visit root_path
    click_link "A Tale of Two Cities"

    expect(page).to have_css "h4", text: "A Tale of Two Cities | 2015-01-01"
    expect(page).to have_css "h5", text: "By Charles Dickens"
    expect(page).to have_css "p", text: "This is a book!"
  end

  scenario "Displaying a book with an unknown author" do
    book = Book.create! title: "A Tale of Two Cities"

    visit book_path(book)

    expect(page).to have_css "h5", text: "By unknown"
  end

  scenario "Displaying a book with cover image" do
    book = Book.create! title: "A Tale of Two Cities",
                        cover_image: Rack::Test::UploadedFile.new("spec/resources/test.txt")

    visit book_path(book)

    expect(page).to have_css "img[src='#{book.image_url}']"
  end

  scenario "Adding a book" do
    expect(Book.count).to eq 0

    visit root_path
    click_link "Add Book"
    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      fill_in "Author", with: "Charles Dickens"
      fill_in "Date Published", with: "1859-04-01"
      fill_in "Description", with: "A novel by Charles Dickens"
      click_button "Save"
    end

    expect(page).to have_content "Added Book"
    expect(Book.count).to eq 1

    book = Book.first
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.author).to eq "Charles Dickens"
    expect(book.published_on).to eq Date.parse("1859-04-01")
    expect(book.description).to eq "A novel by Charles Dickens"
  end

  scenario "Logged in user adding a book" do
    expect(Book.count).to eq 0

    visit root_path
    click_link "Login"
    click_link "Add Book"
    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      fill_in "Author", with: "Charles Dickens"
      click_button "Save"
    end

    expect(page).to have_content "Added Book"
    expect(Book.count).to eq 1

    book = Book.first
    expect(book.creator_id).to eq 123456
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.author).to eq "Charles Dickens"
  end

  scenario "Adding a book with image" do
    visit root_path
    click_link "Add Book"
    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      attach_file "Cover image", "spec/resources/test.txt"
      click_button "Save"
    end

    expect(page).to have_content "Added Book"
    expect(Book.count).to eq 1

    book = Book.first
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.image_url).to end_with "/cover_images/#{book.id}/test.txt"

    expect(StorageBucket.files.all.count).to eq 1
    file = StorageBucket.files.first
    expect(file.key).to eq "cover_images/#{book.id}/test.txt"
    expect(file.body).to include "Test file."
  end

  scenario "Adding a book with missing fields" do
    expect(Book.count).to eq 0

    visit root_path
    click_link "Add Book"
    within "form.new_book" do
      click_button "Save"
    end

    expect(page).to have_content "Title can't be blank"
    expect(Book.count).to eq 0

    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      click_button "Save"
    end

    expect(Book.count).to eq 1
    expect(Book.first.title).to eq "A Tale of Two Cities"
  end

  scenario "Editing a book" do
    book = Book.create! title: "A Tale of Two Cities", author: "Charles Dickens"

    visit root_path
    click_link "A Tale of Two Cities"
    click_link "Edit Book"
    fill_in "Title", with: "CHANGED!"
    click_button "Save"

    expect(page).to have_content "Updated Book"

    book.reload
    expect(book.title).to eq "CHANGED!"
    expect(book.author).to eq "Charles Dickens"
  end

  scenario "Editing a book's cover image" do
    book = Book.create! title: "A Tale of Two Cities",
                        cover_image: Rack::Test::UploadedFile.new("spec/resources/test.txt")

    visit root_path
    click_link "A Tale of Two Cities"
    click_link "Edit Book"
    attach_file "Cover image", "spec/resources/test-2.txt"
    click_button "Save"

    expect(page).to have_content "Updated Book"
    expect(StorageBucket.files.get "cover_images/#{book.id}/test-2.txt").to be_present
    expect(StorageBucket.files.get "cover_images/#{book.id}/test.txt").to be_nil

    book.reload
    expect(book.image_url).to end_with "/cover_images/#{book.id}/test-2.txt"
  end

  scenario "Editing a book with missing fields" do
    book = Book.create! title: "A Tale of Two Cities"

    visit root_path
    click_link "A Tale of Two Cities"
    click_link "Edit Book"
    fill_in "Title", with: ""
    click_button "Save"

    expect(page).to have_content "Title can't be blank"
    book.reload
    expect(book.title).to eq "A Tale of Two Cities"

    within "form.edit_book" do
      fill_in "Title", with: "CHANGED!"
      click_button "Save"
    end

    book.reload
    expect(book.title).to eq "CHANGED!"
  end

  scenario "Deleting a book" do
    book = Book.create! title: "A Tale of Two Cities", author: "Charles Dickens"
    expect(Book.exists? book.id).to be true

    visit root_path
    click_link "A Tale of Two Cities"
    click_link "Delete Book"

    expect(Book.exists? book.id).to be false
  end

  scenario "Deleting a book with an image" do
    book = Book.create! title: "A Tale of Two Cities",
                        cover_image: Rack::Test::UploadedFile.new("spec/resources/test.txt")

    image_key = "cover_images/#{book.id}/test.txt"
    expect(StorageBucket.files.get image_key).to be_present

    visit root_path
    click_link "A Tale of Two Cities"
    click_link "Delete Book"

    expect(Book.exists? book.id).to be false
    expect(StorageBucket.files.get image_key).to be_nil
  end
end

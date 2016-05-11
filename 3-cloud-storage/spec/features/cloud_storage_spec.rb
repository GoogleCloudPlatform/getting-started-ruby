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

RSpec.shared_examples "Using Cloud Storage" do
  scenario "Displaying cover images in book listing" do
    book = Book.create! title: "A Tale of Two Cities",
                        cover_image: Rack::Test::UploadedFile.new("spec/resources/test.txt")

    visit root_path

    expect(page).to have_content "A Tale of Two Cities"
    expect(page).to have_css "img[src='#{book.image_url}']"
  end

  scenario "Displaying cover image on book page" do
    book = Book.create! title: "A Tale of Two Cities",
                        cover_image: Rack::Test::UploadedFile.new("spec/resources/test.txt")

    visit book_path(book)

    expect(page).to have_css "img[src='#{book.image_url}']"
  end

  scenario "Adding a book with an image" do
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

feature "[Datastore] Using Cloud Storage", :datastore do
  include_examples "Using Cloud Storage"
end

feature "[SQL] Using Cloud Storage" do
  include_examples "Using Cloud Storage"
end

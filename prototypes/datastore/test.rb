ENV["RACK_ENV"] ||= "test"

require "rspec"
require "capybara"

Capybara.app, _ = Rack::Builder.parse_file "config.ru"

RSpec.describe "App that uses Datastore" do
  include Capybara::DSL

  before do
    delete_all_books!
  end

  def delete_all_books!
    query = Gcloud::Datastore::Query.new.kind "Book"
    loop do
      books = Dataset.run query
      if books.any?
        Dataset.delete *books
      else
        break
      end
    end
  end

  def all_books
    query = Gcloud::Datastore::Query.new.kind "Book"
    Dataset.run query
  end

  def insert_book title:, author:
    book = Gcloud::Datastore::Entity.new
    book.key = Gcloud::Datastore::Key.new "Book"
    book["title"] = title
    book["author"] = author
    entities_saved = Dataset.save book
    return entities_saved.first.key.id
  end
  
  it "lists books" do
    expect(all_books.length).to eq 0

    visit "/"
    expect(page).to have_content "There are no books!"

    insert_book title: "A Tale of Two Cities", author: "Charles Dickens"

    visit "/"
    expect(page).not_to have_content "There are no books!"
    expect(page).to have_content "A Tale of Two Cities -by- Charles Dickens"
  end

  it "can create books" do
    expect(all_books.length).to eq 0

    visit "/"
    fill_in "title", with: "A Tale of Two Cities"
    fill_in "author", with: "Charles Dickens"
    click_button "Add book"

    expect(all_books.length).to eq 1
    expect(all_books.first["title"]).to eq "A Tale of Two Cities"
    expect(all_books.first["author"]).to eq "Charles Dickens"
  end

  it "can delete books" do
    book1_ID = insert_book title: "A Tale of Two Cities", author: "Charles Dickens"
    book2_ID = insert_book title: "Alice's Adventures in Wonderland", author: "Lewis Carroll"
    expect(all_books.length).to eq 2
    
    visit "/"
    within "#book_#{book1_ID}" do
      click_button "X"
    end

    expect(all_books.length).to eq 1
    expect(all_books.first["title"]).to eq "Alice's Adventures in Wonderland"
    expect(all_books.first["author"]).to eq "Lewis Carroll"
  end

end

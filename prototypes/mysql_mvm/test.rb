ENV["RACK_ENV"] ||= "test"

require "rspec"
require "capybara"

Capybara.app, _ = Rack::Builder.parse_file "config.ru"

RSpec.describe "App that uses SQL" do
  include Capybara::DSL

  before do
    DB[:books].truncate
  end
  
  it "lists books" do
    expect(DB[:books].count).to eq 0

    visit "/"
    expect(page).to have_content "There are no books!"

    DB[:books].insert title: "A Tale of Two Cities", author: "Charles Dickens"

    visit "/"
    expect(page).not_to have_content "There are no books!"
    expect(page).to have_content "A Tale of Two Cities -by- Charles Dickens"
  end

  it "can create books" do
    expect(DB[:books].count).to eq 0

    visit "/"
    fill_in "title", with: "A Tale of Two Cities"
    fill_in "author", with: "Charles Dickens"
    click_button "Add book"

    expect(DB[:books].count).to eq 1
    expect(DB[:books].first[:title]).to eq "A Tale of Two Cities"
    expect(DB[:books].first[:author]).to eq "Charles Dickens"
  end

  it "can delete books" do
    book1_ID = DB[:books].insert title: "A Tale of Two Cities", author: "Charles Dickens"
    book2_ID = DB[:books].insert title: "Alice's Adventures in Wonderland", author: "Lewis Carroll"
    expect(DB[:books].count).to eq 2
    
    visit "/"
    within "#book_#{book1_ID}" do
      click_button "X"
    end

    expect(DB[:books].count).to eq 1
    expect(DB[:books].first[:title]).to eq "Alice's Adventures in Wonderland"
    expect(DB[:books].first[:author]).to eq "Lewis Carroll"
  end

end

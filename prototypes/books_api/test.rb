require_relative "app"

require "rspec"
require "rack"
require "rack/test"
require "ostruct"

RSpec.describe "Book Finder" do

  describe "#search_books" do

    it "can search for books by title (Client Library mocking)" do
      book_response = OpenStruct.new(
        self_link: "https://link/to/book",
        volume_info: OpenStruct.new(
          title: "A Tale of Two Cities",
          authors: ["Charles Dickens"]
        )
      )
      api_response = OpenStruct.new data: OpenStruct.new(items: [book_response])

      expect(ApiClient).to receive(:execute).with(
        api_method: BooksApi.volumes.list,
        parameters: { q: "A Tale of Two Cities", intitle: true, order_by: "relevance" }
      ).and_return api_response

      books = search_books "A Tale of Two Cities"

      expect(books).to eq [{
        title: "A Tale of Two Cities",
        authors: ["Charles Dickens"],
        link: "https://link/to/book",
        image: nil
      }]
    end

    it "can search for books by title (API mocking)" do
      api_response = {
        kind: "books#volumes",
        items: [
          {
            kind: "books#volume",
            id: "1234567",
            selfLink: "https://www.googleapis.com/books/v1/volumes/1234567",
            volumeInfo: {
              title: "A Tale of Two Cities",
              authors: ["Charles Dickens"],
              imageLinks: {
                thumbnail: "http://bks2.books.google.com/books/content?id=1234567"
              }
            }
          }
        ]
      }

      test_connection = Faraday.new do |builder|
        builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
          # https://www.googleapis.com/books/v1/volumes?intitle=true&order_by=relevance&q=<query>
          stub.get("/books/v1/volumes") do |env|
            expect(env.params["q"]).to eq "A Tale of Two Cities"
            expect(env.params["intitle"]).to eq "true"
            expect(env.params["order_by"]).to eq "relevance"
            [200, {"Content-Type" => "application/json"}, api_response.to_json]
          end
        end
      end

      allow(ApiClient).to receive(:connection).and_return test_connection

      books = search_books "A Tale of Two Cities"

      expect(books).to eq [{
        title: "A Tale of Two Cities",
        authors: ["Charles Dickens"],
        link: "https://www.googleapis.com/books/v1/volumes/1234567",
        image: "http://bks2.books.google.com/books/content?id=1234567"
      }]
    end
  end

  describe "API" do
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    it "can query books and receive JSON response from API" do
      expect_any_instance_of(Sinatra::Application).to receive(:search_books).and_return([
        {
          title: "A Tale of Two Cities",
          authors: ["Charles Dickens"],
          image: "http://path/to/image",
          link: "http://path/to/book"
        }
      ])

      get "/search?q=A%20Tale%20of%20Two%20Cities"

      expect(last_response.status).to eq 200
      expect(last_response["Content-Type"]).to eq "application/json"

      books = JSON.parse last_response.body

      expect(books.length).to eq 1
      expect(books.first["title"]).to eq "A Tale of Two Cities"
      expect(books.first["authors"]).to eq ["Charles Dickens"]
      expect(books.first["image"]).to eq "http://path/to/image"
      expect(books.first["link"]).to eq "http://path/to/book"
    end
  end
end

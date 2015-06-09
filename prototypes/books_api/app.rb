require "google/api_client"
require "ostruct"
require "sinatra"
require "slim"

ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "key.json"

ApiClient = Google::APIClient.new application_name: "Book Finder"
ApiClient.authorization = :google_app_default
ApiClient.authorization.scope = "https://www.googleapis.com/auth/books"
ApiClient.authorization.fetch_access_token!

BooksApi = ApiClient.discovered_api "books"

def search_books query
  results = ApiClient.execute(
    api_method: BooksApi.volumes.list,
    parameters: { q: query, intitle: true, order_by: "relevance" }
  )
  results.data.items.map do |item|
    {
      title: item.volume_info.title,
      authors: item.volume_info.authors,
      image: item.volume_info.image_links ? item.volume_info.image_links.thumbnail : nil,
      link: item.self_link
    }
  end
rescue Exception => ex
  # Don't share the full exception with the end-user in a real app.
  # Instead, log it and it will appear in the Console under Monitoring > Logs
  { error: ex }
end

get "/" do
  slim :index
end

get "/search" do
  content_type "application/json"
  search_books(params[:q]).to_json
end

__END__

@@ index
doctype html
html
  head
    title Book Finder
  body
    form action="/search"
      input name="q" placeholder="Book search query" autofocus="autofocus"
      input type="submit" value="Search"

    ul.books

    css:
      body {
        padding-top: 10px;
      }
      form {
        text-align: center;
      }
      form input {
        font-size: 25px;
        margin-left: 10px;
      }
      ul.books {
         list-style-type: none;
         text-align: center;
      }
      ul.books li {
        margin-bottom: 15px;
      }
      ul.books li a {
        display: block;
        font-size: 20px;
        text-decoration: none;
        margin-bottom: 5px;
        color: rgb(28, 106, 174);
      }

    javascript:
      var searching = false
      var searchField = document.querySelector("input[name=q]")
      var bookList = document.querySelector("ul.books")

      function searchBooks() {
        if (searching)
          return
        else
          searching = true

        var query = searchField.value

        request = new XMLHttpRequest()
        request.onload = function() {
          var books = JSON.parse(request.responseText)
          if (books.error)
            console.error(books.error)
          else
            displayBooks(books)
          searching = false
        }
        request.open("GET", "/search?q=" + encodeURIComponent(query))
        request.send()
      }

      function displayBooks(books) {
        var items = []
        books.forEach(function(book) {
          var descriptionLink = document.createElement("a")
          descriptionLink.innerText = book.title + " -by- " + book.authors.join(" & ")
          descriptionLink.href = book.link

          if (book.image) {
            var image = document.createElement("img")
            image.src = book.image
          }

          var item = document.createElement("li")
          item.appendChild(descriptionLink)
          if (book.image)
            item.appendChild(image)
          items.push(item)
        })
        while (bookList.childElementCount > 0)
          bookList.removeChild(bookList.childNodes[0])
        items.forEach(function(item) {
          bookList.appendChild(item)
        })
      }

      document.querySelector("form").addEventListener("submit", function(e) {
        e.preventDefault()
        searchBooks()
      })

      document.querySelector("form").addEventListener("keydown", function(e) {
        searchBooks()
      });

require "sinatra"
require "slim"
require "yaml"
require "gcloud/datastore"

ENV["RACK_ENV"] ||= "development"

datastore_config = YAML.load_file("datastore.yml")[ENV["RACK_ENV"]]

Dataset = Gcloud.datastore datastore_config["dataset_id"], datastore_config["keyfile"]

if datastore_config.has_key? "host"
  Gcloud::Datastore::Connection::API_URL = datastore_config["host"]
end

get "/" do
  query = Gcloud::Datastore::Query.new.kind "Book"
  @books = Dataset.run query
  slim :index
end

post "/books" do
  book = Gcloud::Datastore::Entity.new
  book.key = Gcloud::Datastore::Key.new "Book"
  book["title"] = params["title"]
  book["author"] = params["author"]
  Dataset.save book
  redirect "/"
end

delete "/books/:id" do
  Dataset.delete Gcloud::Datastore::Key.new("Book", params["id"].to_i)
  redirect "/"
end

get "/_ah/health" do
  "ok"
end

__END__

@@ index
doctype html
html
  head
    title Ruby Datastore Sample
  body
    - if @books.any?
      h2 Books
      ul
        - @books.each do |book|
          li id="book_#{book.key.id}"
            | #{book["title"]} -by- #{book["author"]}
            form method="post" action="/books/#{book.key.id}" style="display: inline;"
              input type="hidden" name="_method" value="delete"
              input type="submit" value="X"
    - else
      p There are no books!

    fieldset
      legend Add book
      form method="post" action="/books"
        input name="title" placeholder="Book title"
        input name="author" placeholder="Book author"
        input type="submit" value="Add book"

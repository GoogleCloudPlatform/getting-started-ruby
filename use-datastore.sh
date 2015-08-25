#! /bin/sh
set -ex
cp structured_data/datastore/book.rb             app/models/book.rb
cp structured_data/datastore/books_controller.rb app/controllers/books_controller.rb
cp structured_data/datastore/index.html.erb      app/views/books/index.html.erb

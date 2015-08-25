#! /bin/sh
set -ex
cp structured_data/sql/book.rb             app/models/book.rb
cp structured_data/sql/books_controller.rb app/controllers/books_controller.rb
cp structured_data/sql/index.html.erb      app/views/books/index.html.erb

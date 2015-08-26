#! /bin/sh
set -ex
cp structured_data/sql/application.rb            config/
cp structured_data/sql/book.rb                   app/models/
cp structured_data/sql/books_controller.rb       app/controllers/
cp structured_data/sql/user_books_controller.rb  app/controllers/
cp structured_data/sql/index.html.erb            app/views/books/
cp structured_data/sql/_pagination_link.html.erb app/views/user_books/

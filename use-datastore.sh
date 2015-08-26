#! /bin/sh
set -ex
cp structured_data/datastore/application.rb            config/
cp structured_data/datastore/book.rb                   app/models/
cp structured_data/datastore/books_controller.rb       app/controllers/
cp structured_data/datastore/user_books_controller.rb  app/controllers/
cp structured_data/datastore/index.html.erb            app/views/books/
cp structured_data/datastore/_pagination_link.html.erb app/views/user_books/

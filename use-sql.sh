#! /bin/sh
set -ex
cp structured_data/sql/application.rb      config/
cp structured_data/sql/book.rb             app/models/
cp structured_data/sql/books_controller.rb app/controllers/

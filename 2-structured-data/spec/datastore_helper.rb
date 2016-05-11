require "datastore_book_extensions"

def configure_datastore config
  config.before :all, :datastore do
    # Extend Datastore Book model with additional methods useful for testing.
    # These methods are not included in the app's Book model for simplicity.
    DatastoreBook.send :extend, DatastoreBookExtensions 
  end

  config.before :each, :datastore do
    stub_const "Book", DatastoreBook
    stub_const "BooksController", DatastoreBooksController
    DatastoreBook.delete_all
  end

  config.after :all, :datastore do
    # Reload application to change Book model and controller classes
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!
  end
end

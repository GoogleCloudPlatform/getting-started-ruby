require "datastore_book_extensions"

def configure_datastore config
  config.before :all, :datastore do
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!

    # Extend Datastore Book model with additional methods useful for testing.
    # These methods are not included in the app's Book model for simplicity.
    DatastoreBook.send :include, DatastoreBookExtensions 
  end

  config.before :each, :datastore do
    stub_const "Book", DatastoreBook
    stub_const "BooksController", DatastoreBooksController
    DatastoreBook.delete_all
  end

  config.after :all, :datastore do
    # Reload application to cleanup Book model and controller class changes
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!
  end
end

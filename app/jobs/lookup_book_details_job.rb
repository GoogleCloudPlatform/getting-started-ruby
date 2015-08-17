class LookupBookDetailsJob < ActiveJob::Base
  queue_as :default

  def perform book
    # test
    book.update title: book.title.upcase
  end
end

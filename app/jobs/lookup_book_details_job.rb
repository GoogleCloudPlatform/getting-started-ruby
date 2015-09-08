# [START lookup_books]
require "google/api_client"

class LookupBookDetailsJob < ActiveJob::Base
  queue_as :default

  def perform book
    Rails.logger.info "(#{book.id}) Lookup book details for #{book.title.inspect}"

    # Create Books API client
    api_client = Google::APIClient.new application_name: "Bookshelf Sample Application"
    api_client.authorization = nil # Books API does not require authorization
    books_api = api_client.discovered_api "books"

    result = api_client.execute(
      api_method: books_api.volumes.list,
      parameters: { q: book.title, order_by: "relevance" } # what is the default order?  can we leave off "relevance" and get consistently good results?
    )

    # Lookup a list of relevant books based on the provided book title.
    volumes = result.data.items
# [END lookup_books]

    # [START choose_volume]
    # To provide the best results, find the first returned book that
    # includes title and author information as well as a book cover image.
    best_match = volumes.find {|volume|
      info = volume.volume_info
      info.title && info.authors && info.image_links.try(:thumbnail)
    }

    volume = best_match || volumes.first
    # [END choose_volume]

    # [START update_book]
    if volume
      info   = volume.volume_info
      images = info.image_links

      publication_date = info.published_date
      publication_date = "#{$1}-01-01" if publication_date =~ /^(\d{4})$/
      publication_date = Date.parse publication_date

      book.author       = info.authors.join(", ") unless book.author.present?
      book.published_on = publication_date        unless book.published_on.present?
      book.description  = info.description        unless book.description.present?
      book.image_url    = images.try(:thumbnail)  unless book.image_url.present?
      book.save
    end
    # [END update_book]

    Rails.logger.info "(#{book.id}) Complete"
  end
end
# [END book_lookup]

__END__

New (Upcoming) Alpha google-api-client API

require "google/apis/books_v1"

BooksAPI = Google::Apis::BooksV1

class LookupBookDetailsJob < ActiveJob::Base
  queue_as :default

  def perform book
    puts "Lookup details for book #{book.id} #{book.title.inspect}"

    book_service = BooksAPI::BooksService.new
    book_service.authorization = Google::Auth.get_application_default [BooksAPI::AUTH_BOOKS]

    book_service.list_volumes book.title, order_by: "relevance" do |results, error|
      # TODO clean up error condition
      if error
        puts "ERROR!"
        puts error
        puts error.inspect
        raise "BookService list_volumes ERROR!"
      end

      volumes = results.items

      best_match = volumes.find {|volume|
        info = volume.volume_info
        info.title && info.authors && info.image_links.try(:thumbnail)
      }

      volume = best_match || volumes.first

      if volume
        info   = volume.volume_info
        images = info.image_links

        book.author       = info.authors.join(", ") unless book.author.present?
        book.published_on = info.published_date     unless book.published_on.present?
        book.description  = info.description        unless book.description.present?
        book.image_url    = images.try(:thumbnail)  unless book.image_url.present?
        book.save
      end
    end
  end
end

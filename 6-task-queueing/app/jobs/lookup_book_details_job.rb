# [START lookup_books]
require "google/apis/books_v1"

BooksAPI = Google::Apis::BooksV1

class LookupBookDetailsJob < ActiveJob::Base
  queue_as :default

  def perform book
    Rails.logger.info "Lookup details for book #{book.id} #{book.title.inspect}"

    # Create Book API Client
    book_service = BooksAPI::BooksService.new
    book_service.authorization = nil # Books API does not require authentication

    # Lookup a list of relevant books based on the provided book title.
    book_service.list_volumes book.title, order_by: "relevance" do |results, error|
      if error
        Rails.logger.error "[BookService] " + error
        raise "BookService list_volumes ERROR!"
      end

      # List of relevant books
      volumes = results.items
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
        book.published_on = publication_date     unless book.published_on.present?
        book.description  = info.description        unless book.description.present?
        book.image_url    = images.try(:thumbnail)  unless book.image_url.present?
        book.save
      end
      # [END update_book]

      Rails.logger.info "(#{book.id}) Complete"
    end
  end
end
# [END book_lookup]


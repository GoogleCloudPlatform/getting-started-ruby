# TODO fix ... why isn't it working without this?
ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "key.json" # default not working?

# TODO test

# [START book_lookup]
require "google/api_client"

class LookupBookDetailsJob < ActiveJob::Base
  queue_as :default

  def perform book
    puts "Lookup details for book #{book.id} #{book.title.inspect}"

    api_client = Google::APIClient.new application_name: "Bookshelf Sample Application"
    api_client.authorization = :google_app_default
    api_client.authorization.scope = "https://www.googleapis.com/auth/books"
    api_client.authorization.fetch_access_token!

    books_api = api_client.discovered_api "books"

    result = api_client.execute(
      api_method: books_api.volumes.list,
      parameters: { q: book.title, order_by: "relevance" } # what is the default order?  can we leave off "relevance" and get consistently good results?
    )

    volumes = result.data.items

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
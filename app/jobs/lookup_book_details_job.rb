require "google/api_client"

class LookupBookDetailsJob < ActiveJob::Base
  queue_as :default

  def perform book
    puts "PERFORM LookupBookDetailsJob"
    puts book.inspect
    puts

    api_client = Google::APIClient.new application_name: "Bookshelf Sample Application"
    api_client.authorization = :google_app_default
    api_client.authorization.scope = "https://www.googleapis.com/auth/books"
    api_client.authorization.fetch_access_token!

    books_api = api_client.discovered_api "books"

    results = api_client.execute(
      api_method: books_api.volumes.list,
      parameters: { q: book.title, intitle: true, order_by: "relevance" }
    )

    puts results
    puts results.inspect

    # check results.response.status

    puts "BOOK API RESULTS (#{results.data.items.length})"

    results.data.items.each do |item|
      puts "[#{item.volumn_info.title}]"
      puts
      puts item.inspect
      puts
      if item.volume_info.title == book.title
        book.author = item.volume_info.authors.join(", ")                        unless book.author.present?
        book.image_url = item.volume_info.try(:image_links).try(:[], :thumbnail) unless book.image_url.present?
        book.save

        break
      end
    end
  rescue Exception => ex
    puts "EXCEPTION IN JOB"
    puts ex
    puts ex.inspect
  end
end

# [START pub_sub_queue_adapter]
require "gcloud"

module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def self.pubsub
        gcloud = Gcloud.new ENV["PROJECT_ID"] # settings.project_id

        gcloud.pubsub
      end

      def self.enqueue job
        book  = job.arguments.first
        topic = pubsub.topic "lookup_book_details_queue"

        topic.publish book.id.to_s
      end

      def self.run_worker!
        Rails.logger = Logger.new(STDOUT)
        Rails.logger.info "Running worker to lookup book details"

        topic        = pubsub.topic       "lookup_book_details_queue"
        subscription = topic.subscription "lookup_book_details"

        topic.subscribe "lookup_book_details" unless subscription.exists?

        subscription.listen autoack: true do |message|
          Rails.logger.info "Book lookup request (#{message.data})"

          book_id = message.data.to_i
          book    = Book.find_by_id book_id

          LookupBookDetailsJob.perform_now book if book
        end
      end

    end
  end
end
# [END pub_sub_queue_adapter]

__END__

#<LookupBookDetailsJob:0x007fbed925c4d0 @arguments=[#<Book id: 39, title: "jurassic park", author: "", published_on: nil, description: "", created_at: "2015-08-17 13:51:11", updated_at: "2015-08-17 13:51:11", image_url: nil, creator_id: nil>], @job_id="ca0828f0-0d27-4377-9726-63fdbffec765", @queue_name="default">

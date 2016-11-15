# [START pub_sub_enqueue]
require "google/cloud"

module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def self.pubsub
        project_id = Rails.application.config.x.settings["project_id"]
        gcloud     = Google::Cloud.new project_id

        gcloud.pubsub
      end

      def self.enqueue job
        Rails.logger.info "[PubSubQueueAdapter] enqueue job #{job.inspect}"

        book  = job.arguments.first
        topic = pubsub.topic "lookup_book_details_queue"

        topic.publish book.id.to_s
      end
# [END pub_sub_enqueue]

      # TODO add queue parameter

      # [START pub_sub_worker]
      def self.run_worker!
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
      # [END pub_sub_worker]

    end
  end
end

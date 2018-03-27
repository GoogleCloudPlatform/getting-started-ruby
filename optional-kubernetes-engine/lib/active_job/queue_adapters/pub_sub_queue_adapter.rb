# [START pub_sub_enqueue]
require "google/cloud/pubsub"

module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def self.pubsub
        @pubsub ||= begin
          project_id = Rails.application.config.x.settings["project_id"]
          Google::Cloud::Pubsub.new project_id: project_id
        end
      end

      def self.pubsub_topic
        @pubsub_topic ||= Rails.application.config.x.settings["pubsub_topic"]
      end

      def self.pubsub_subscription
        @pubsub_subscription ||= Rails.application.config.x.settings["pubsub_subscription"]
      end

      def self.enqueue job
        Rails.logger.info "[PubSubQueueAdapter] enqueue job #{job.inspect}"

        book  = job.arguments.first

        topic = pubsub.topic pubsub_topic

        topic.publish book.id.to_s
      end
# [END pub_sub_enqueue]

      # [START pub_sub_worker]
      def self.run_worker!
        Rails.logger.info "Running worker to lookup book details"

        topic        = pubsub.topic pubsub_topic
        subscription = topic.subscription pubsub_subscription

        subscriber = subscription.listen do |message|
          message.acknowledge!

          Rails.logger.info "Book lookup request (#{message.data})"

          book_id = message.data.to_i
          book    = Book.find_by_id book_id

          LookupBookDetailsJob.perform_now book if book
        end

        # Start background threads that will call block passed to listen.
        subscriber.start

        # Fade into a deep sleep as worker will run indefinitely
        sleep
     end
      # [END pub_sub_worker]

    end
  end
end

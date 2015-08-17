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
        topic = pubsub.topic "lookup_book_details_queue"

        topic.publish book.id.to_s
      end

      def self.run_worker!
        topic        = pubsub.topic "lookup_book_details_queue"
        subscription = topic.subscription "lookup_book_details"
        
        subscription.listen autoack: true do |message|
          puts "Message received #{message.data.inspect}"

          book_id = message.data.to_i
          book    = Book.find book_id

          LookupBookDetailsJob.perform_now book
        end
      end

    end
  end
end
# [END pub_sub_queue_adapter]

__END__

#<LookupBookDetailsJob:0x007fbed925c4d0 @arguments=[#<Book id: 39, title: "jurassic park", author: "", published_on: nil, description: "", created_at: "2015-08-17 13:51:11", updated_at: "2015-08-17 13:51:11", image_url: nil, creator_id: nil>], @job_id="ca0828f0-0d27-4377-9726-63fdbffec765", @queue_name="default">

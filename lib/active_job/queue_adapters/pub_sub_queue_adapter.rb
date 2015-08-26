# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START pub_sub_enqueue]
require "gcloud"

module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def self.pubsub
        project_id = Rails.application.config.x.settings["project_id"]
        gcloud     = Gcloud.new project_id

        gcloud.pubsub
      end

      def self.enqueue job
        book  = job.arguments.first
        topic = pubsub.topic "lookup_book_details_queue"

        topic.publish book.id.to_s
      end
# [END pub_sub_enqueue]

      # [START pub_sub_worker]
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
      # [END pub_sub_worker]

    end
  end
end

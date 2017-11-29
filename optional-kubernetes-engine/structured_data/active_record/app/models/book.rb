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

class Book < ActiveRecord::Base
  validates :title, presence: true

  attr_accessor :cover_image

  after_create   :upload_image, if: :cover_image
  before_update  :update_image, if: :cover_image
  before_destroy :delete_image, if: :image_url

  # [START enqueue_job]
  after_create :lookup_book_details

  private

  def lookup_book_details
    if [author, description, published_on, image_url].any? {|attr| attr.blank? }
      LookupBookDetailsJob.perform_later self
    end
  end
  # [END enqueue_job]

  def upload_image
    image = StorageBucket.files.new(
      key: "cover_images/#{id}/#{cover_image.original_filename}",
      body: cover_image.read,
      public: true
    )

    image.save

    update_columns image_url: image.public_url
  end

  def delete_image
    bucket_name = StorageBucket.key
    image_uri   = URI.parse image_url

    if image_uri.host == "#{bucket_name}.storage.googleapis.com"
      # Remove leading forward slash from image path
      # The result will be the image key, eg. "cover_images/:id/:filename"
      image_key = image_uri.path.sub("/", "")
      image     = StorageBucket.files.new key: image_key

      image.destroy
    end
  end

  def update_image
    delete_image if image_url?
    upload_image
  end
end

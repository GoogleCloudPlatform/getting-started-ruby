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

require "google/cloud/datastore"
require "google/cloud/storage"

class Book
  def self.storage_bucket
    @storage_bucket ||= begin
      config = Rails.application.config.x.settings
      storage = Google::Cloud::Storage.new project_id: config["project_id"],
                                           credentials: config["keyfile"]
      storage.bucket config["gcs_bucket"]
    end
  end

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id, :title, :author, :published_on, :description, :image_url,
                :cover_image, :creator_id

  validates :title, presence: true

  # Return a Google::Cloud::Datastore::Dataset for the configured dataset.
  # The dataset is used to create, read, update, and delete entity objects.
  def self.dataset
    @dataset ||= Google::Cloud::Datastore.new(
      project_id: Rails.application.config.
                        database_configuration[Rails.env]["dataset_id"]
    )
  end

  # Query Book entities from Cloud Datastore.
  #
  # returns an array of Book query results and a cursor
  # that can be used to query for additional results.
  # [START books_by_creator]
  def self.query options = {}
    query = Google::Cloud::Datastore::Query.new
    query.kind "Book"
    query.limit options[:limit]   if options[:limit]
    query.cursor options[:cursor] if options[:cursor]

    if options[:creator_id]
      query.where "creator_id", "=", options[:creator_id]
    end
    # [END books_by_creator]

    results = dataset.run query
    books   = results.map {|entity| Book.from_entity entity }

    if options[:limit] && results.size == options[:limit]
      next_cursor = results.cursor
    end

    return books, next_cursor
  end

  def self.from_entity entity
    book = Book.new
    book.id = entity.key.id
    entity.properties.to_hash.each do |name, value|
      book.send "#{name}=", value if book.respond_to? "#{name}="
    end
    book
  end

  # Lookup Book by ID.  Returns Book or nil.
  def self.find id
    query    = Google::Cloud::Datastore::Key.new "Book", id.to_i
    entities = dataset.lookup query

    from_entity entities.first if entities.any?
  end

  # alias "find_by_id" for compatibility with Active Record
  singleton_class.send(:alias_method, :find_by_id, :find)

  def to_entity
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "Book", id
    entity["title"]        = title
    entity["author"]       = author               if author.present?
    entity["published_on"] = published_on.to_time if published_on.present?
    entity["description"]  = description          if description.present?
    entity["image_url"]    = image_url            if image_url.present?
    entity["creator_id"]   = creator_id           if creator_id.present?
    entity
  end

  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value
    end
    save
  end

  def destroy
    delete_image if image_url.present?

    Book.dataset.delete Google::Cloud::Datastore::Key.new "Book", id
  end

  def persisted?
    id.present?
  end

  def upload_image
    file = Book.storage_bucket.create_file \
      cover_image.tempfile,
      "cover_images/#{id}/#{cover_image.original_filename}",
      content_type: cover_image.content_type,
      acl: "public"

    self.image_url = file.public_url

    Book.dataset.save to_entity
  end

  def delete_image
    image_uri = URI.parse image_url

    if image_uri.host == "#{Book.storage_bucket.name}.storage.googleapis.com"
      # Remove leading forward slash from image path
      # The result will be the image key, eg. "cover_images/:id/:filename"
      image_path = image_uri.path.sub("/", "")

      file = Book.storage_bucket.file image_path
      file.delete
    end
  end

  def update_image
    delete_image if image_url.present?
    upload_image
  end

  # [START enqueue_job]
  include GlobalID::Identification

  def save
    if valid?
      entity = to_entity
      Book.dataset.save entity

      # TODO separate create and save ...
      unless persisted? # just saved
        self.id = entity.key.id
        lookup_book_details
      end

      self.id = entity.key.id
      update_image if cover_image.present?
      true
    else
      false
    end
  end

  private

  def lookup_book_details
    if [author, description, published_on, image_url].any? {|attr| attr.blank? }
      LookupBookDetailsJob.perform_later self
    end
  end
  # [END enqueue_job]
end

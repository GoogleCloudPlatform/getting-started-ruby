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

# [START book_class]
# [START firestore_client]
require "google/cloud/datastore"
# [END firestore_client]
require "google/cloud/storage"

class Book

  attr_accessor :id, :title, :author, :published_on, :description, :image_url, :cover_image

  # Return a Google::Cloud::Datastore::Dataset for the configured dataset.
  # The dataset is used to create, read, update, and delete entity objects.
  def self.dataset
    project_id = Rails.application.config.database_configuration[Rails.env]["dataset_id"]
    # [START firestore_client]
    @dataset ||= Google::Cloud::Datastore.new(
      project_id: project_id
    )
    # [END firestore_client]
  end
# [END book_class]

  # [START connect]
  def self.storage_bucket
    @storage_bucket ||= begin
      config = Rails.application.config.x.settings
      storage = Google::Cloud::Storage.new project_id: config["project_id"],
                                           credentials: config["keyfile"]
      raise "project_id does not exist" if ENV["GOOGLE_CLOUD_PROJECT"].nil?
      bucket = storage.bucket ENV["GOOGLE_CLOUD_PROJECT"] + ".appspot.com"
      raise "bucket does not exist" if bucket.nil?
      bucket
    end
  end
  # [END connect]

  # [START query]
  # Query Book entities from Cloud Datastore.
  #
  # returns an array of Book query results and a cursor
  # that can be used to query for additional results.
  def self.query options = {}
    query = Google::Cloud::Datastore::Query.new
    query.kind "Book"
    query.limit options[:limit]   if options[:limit]
    query.cursor options[:cursor] if options[:cursor]

    results = dataset.run query
    books   = results.map {|entity| Book.from_entity entity }

    if options[:limit] && results.size == options[:limit]
      next_cursor = results.cursor
    end

    return books, next_cursor
  end
  # [END query]

  # [START from_entity]
  def self.from_entity entity
    book = Book.new
    book.id = entity.key.id
    entity.properties.to_hash.each do |name, value|
      book.send "#{name}=", value if book.respond_to? "#{name}="
    end
    book
  end
  # [END from_entity]

  # [START firestore_client_get_book]
  # Lookup Book by ID.  Returns Book or nil.
  def self.find id
    query    = Google::Cloud::Datastore::Key.new "Book", id.to_i
    entities = dataset.lookup query

    from_entity entities.first if entities.any?
  end
  # [END firestore_client_get_book]

  # Add Active Model support.
  # Provides constructor that takes a Hash of attribute values.
  include ActiveModel::Model

  # [START save]
  # Save the book to Datastore.
  # @return true if valid and saved successfully, otherwise false.
  def save
    if valid?
      entity = to_entity
      Book.dataset.save entity
      self.id = entity.key.id
      true
    else
      false
    end
  end
  # [END save]

  def create
    upload_image if cover_image
    save
  end

  # [START to_entity]
  # ...
  def to_entity
    entity                 = Google::Cloud::Datastore::Entity.new
    entity.key             = Google::Cloud::Datastore::Key.new "Book", id
    entity["title"]        = title
    entity["author"]       = author       if author
    entity["published_on"] = published_on if published_on
    entity["description"]  = description  if description
    entity["image_url"]    = image_url
    entity
  end
  # [END to_entity]

  # [START validations]
  # Add Active Model validation support to Book class.
  include ActiveModel::Validations

  validates :title, presence: true
  # [END validations]

  # [START update]
  # Set attribute values from provided Hash and save to Datastore.
  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value if respond_to? "#{name}="
    end
    update_image if cover_image
    save
  end

  def update_image
    delete_image if image_url
    upload_image
  end
  # [END update]

  # [START upload]
  def upload_image
    file = Book.storage_bucket.create_file \
      cover_image.tempfile,
      "cover_images/#{id}/#{cover_image.original_filename}",
      content_type: cover_image.content_type,
      acl: "public"
    @image_url = file.public_url
  end
  # [END upload]

  # [START destroy]
  def destroy
    delete_image if image_url
    Book.dataset.delete Google::Cloud::Datastore::Key.new "Book", id
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
  # [END destroy]
##################

  def persisted?
    id.present?
  end
end
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
require "gcloud/datastore"

class Book

  attr_accessor :id, :title, :author, :published_on, :description

  # Query Book entities from Cloud Datastore.
  #
  # returns an array of Book query results and a cursor
  # that can be used to query for additional results.
  def self.query options = {}
    query = Gcloud::Datastore::Query.new
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
# [END book_class]

  # [START dataset]
  # Return a Gcloud::Datastore::Dataset for the configured dataset.
  # The dataset is used to create, read, update, and delete entity objects.
  def self.dataset
    @dataset ||= Gcloud.datastore(
      Rails.application.config.database_configuration[Rails.env]["dataset_id"]
    )
  end
  # [END dataset]

  # [START from_entity]
  def self.from_entity entity
    book = Book.new
    book.id = entity.key.id
    entity.properties.to_hash.each do |name, value|
      book.send "#{name}=", value
    end
    book
  end
  # [END from_entity]

  # [START find]
  # Lookup Book by ID.  Returns Book or nil.
  def self.find id
    query    = Gcloud::Datastore::Key.new "Book", id.to_i
    entities = dataset.lookup query

    from_entity entities.first if entities.any?
  end
  # [END find]

  # [START model]
  # ...
  include ActiveModel::Model
  # [END model]

  # [START save]
  # ...
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

  # [START to_entity]
  # ...
  def to_entity
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Book", id
    entity["title"]        = title
    entity["author"]       = author       if author
    entity["published_on"] = published_on if published_on
    entity["description"]  = description  if description
    entity
  end
  # [END to_entity]

  # [START validations]
  # ...
  include ActiveModel::Validations

  validates :title, presence: true
  # [END validations]

  # [START update]
  # ...
  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value
    end
    save
  end
  # [END update]

  # [START destroy]
  def destroy
    Book.dataset.delete Gcloud::Datastore::Key.new "Book", id
  end
  # [END destroy]

##################

  def persisted?
    id.present?
  end
end

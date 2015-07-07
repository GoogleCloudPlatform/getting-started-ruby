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

require "gcloud/datastore" # TODO move to initializer

# TODO mini ORM *after* direct Gcloud access
#      each method should work well in a REGION tag for this version
class Book
  include ActiveModel::Validations
  include ActiveModel::Model
  include ActiveModel::Conversion
  # extend ActiveModel::Naming # for routes?

  def attributes
    {
      "id" => id, "title" => title, "author" => author
    }
  end

  KIND = "Book" # use this :)

  attr_accessor :id, :title, :author, :published_on, :image_url, :description,
                :user_id, :username

  validate :title_or_author_present

  # TODO test
  def persisted?
    id.present?
  end

  def to_entity
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Book", id

    # TODO not hard coded inline
    [:title, :author, :published_on, :image_url, :description, :user_id, :username].each do |attribute|
      entity[attribute.to_s] = send(attribute) unless send(attribute).nil?
    end

    entity
  end

  def self.from_entity entity
    puts "FROM ENTITY #{entity.inspect}"
    book = Book.new
    book.id = entity.key.id
    entity.properties.to_hash.each do |name, value|
      book.send "#{name}=", value
    end
    puts "BOOK #{book.inspect}"
    book
  end

  def save
    entity = to_entity
    self.class.dataset.save entity
    self.id = entity.key.id
    true
  end

  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value
    end
    save
  end

  def destroy
    self.class.dataset.delete Gcloud::Datastore::Key.new "Book", id
  end

  # TODO move to an initializer?  Look @ ActiveRecord::Base#connection
  def self.dataset
    @dataset ||= begin
      config = Rails.application.config.database_configuration[Rails.env]
      if config.has_key?("host")
        Gcloud::Datastore::Connection.const_set :API_URL, config["host"]
      end
      Gcloud.datastore config["dataset_id"], config["keyfile"]
    end
  end

  # TODO pagination (add to SQL first!) - will max out at 1,000
  def self.all
    query = Gcloud::Datastore::Query.new.kind("Book")
    entities = dataset.run query
    entities.map {|entity| Book.from_entity entity }
  end

  # TODO make shared counter?  This'll max out at 1,000
  def self.count
    all.length
  end

  def self.find id
    id = id.to_i if id.is_a?(String) && id =~ /^\d+$/

    puts "FIND #{id}"
    query = Gcloud::Datastore::Key.new "Book", id
    entities = dataset.lookup query

    if entities.any?
      puts "FOUND"
      from_entity entities.first
    else
      puts "NOT FOUND"
    end
  end

  # TODO add validations and failure
  def self.create! attributes = nil
    create attributes
  end

  def self.create attributes = nil
    book = Book.new attributes
    book.save
  end

  def self.delete_all
    query = Gcloud::Datastore::Query.new.kind "Book"
    loop do
      books = dataset.run query
      if books.any?
        dataset.delete *books
      else
        break
      end
    end 
  end

  private

  def title_or_author_present
    if title.blank? && author.blank?
      errors.add :base, "Title or Author must be present"
    end
  end
end

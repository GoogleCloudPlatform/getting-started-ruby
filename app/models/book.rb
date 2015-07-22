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

# In-memory Book implementation
#
# This is NOT intended to be shared.
#
# This exists to render views displaying data without SQL or Datastore dependencies.
class Book
  include ActiveModel::Validations
  include ActiveModel::Model
  include ActiveModel::Conversion

  BOOKS = {}

  attr_accessor :id, :title, :author, :published_on, :description

  validate :title_or_author_present

  def save
    if valid?
      generate_id!
      BOOKS[id] = self
      true
    else
      false
    end
  end

  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value
    end
    save
  end

  def destroy
    BOOKS.delete id if id.present?
  end

  def persisted?
    id.present?
  end

  def reload 
    book = BOOKS[id]
    [:id, :title, :author, :published_on, :description].each do |attribute|
      send "#{attribute}=", book.send(attribute)
    end
  end

  def published_on
    Date.parse(@published_on) if @published_on.present?
  end

  # TODO pagination
  def self.all
    BOOKS.values
  end

  def self.count
    BOOKS.count
  end

  def self.find id
    BOOKS[id.to_i].clone if exists? id.to_i
  end

  def self.first
    BOOKS.values.first.clone
  end

  def self.exists? id
    BOOKS.has_key? id
  end

  def self.create! attributes = nil
    create attributes
  end

  def self.create attributes = nil
    book = Book.new attributes
    book.save
    book.clone
  end

  def self.delete_all
    BOOKS.clear
  end

  def self.next_id!
    @next_id ||= 0
    @next_id += 1
  end

  private

  def title_or_author_present
    if title.blank? && author.blank?
      errors.add :base, "Title or Author must be present"
    end
  end

  def generate_id!
    self.id = Book.next_id! if id.nil?
  end
end

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

# Additional methods added to the Book class for testing only.
module BookExtensions

  def all
    books = []

    query = Gcloud::Datastore::Query.new.kind "Book"

    loop do
      results = dataset.run query

      if results.empty?
        break
      else
        results.each {|entity| books << from_entity(entity) }
        query.cursor results.cursor
        results = dataset.run query
      end
    end

    books
  end

  def first
    all.first
  end

  def count
    all.length
  end

  def delete_all
    query = Gcloud::Datastore::Query.new.kind "Book"
    loop do
      books = dataset.run query
      if books.empty?
        break
      else
        dataset.delete *books
      end
    end
  end

  def exists? id
    find(id).present?
  end

  def create attributes = nil
    book = Book.new attributes
    book.save
    book
  end

  def create! attributes = nil
    book = Book.new attributes
    raise "Book save failed" unless book.save
    book
  end

end

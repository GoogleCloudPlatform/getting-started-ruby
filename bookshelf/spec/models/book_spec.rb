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

require "spec_helper"

RSpec.describe Book do

  it "requires a title or author" do
    expect(Book.new).not_to be_valid

    expect(Book.new title: "title").to be_valid
    expect(Book.new author: "author").to be_valid
    expect(Book.new title: "title", author: "author").to be_valid
  end

  describe "Datastore Persistence" do

    it "can load ::from_entity"

    it "can serialize #to_entity"

    it "can save a book" do
      expect(Book.count).to eq 0

      book = Book.new title: "A Tale of Two Cities"
      book.save

      expect(Book.count).to eq 1
    end

    it "can fetch a book by ID" do
      Book.new(title: "Different Book").save

      book = Book.new title: "A Tale of Two Cities"

      expect(book.id).to be nil
      book.save
      expect(book.id).not_to be nil

      found = Book.find book.id
      expect(found.id).to eq book.id
      expect(found.title).to eq "A Tale of Two Cities"
    end

    it "can delete a book"

    it "can query for books"

    it "can #create a book"

    it "#create! raises on validation error"

    it "#save returns false on validation error"

    it "create returns false on validation error"

    # it "can create an entity with a name key"
    # it "can create an entity with a particular numberic key"

  end

end

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
require "ostruct"

RSpec.describe Book do
  include ActiveJob::TestHelper

  def run_enqueued_jobs!
    enqueued_jobs.each {|job| run_enqueued_job! job }
  end

  def run_enqueued_job! job
    job_class = job[:job]

    job_arguments = job[:args].map do |arg|
      if arg.try :has_key?, "_aj_globalid" # ActiveJob object identifier
        GlobalID::Locator.locate arg["_aj_globalid"]
      else
        arg
      end
    end

    job_class.perform_now *job_arguments

    enqueued_jobs.delete job
  end

  it "requires a title" do
    allow_any_instance_of(Book).to receive(:lookup_book_details)

    expect(Book.new title: nil).not_to be_valid
    expect(Book.new title: "title").to be_valid
  end

  it "book details are automatically looked up when created" do
    expect(enqueued_jobs).to be_empty

    book = Book.create title: "A Tale of Two Cities"

    expect(book.title).to eq "A Tale of Two Cities" # test

    expect(enqueued_jobs.length).to eq 1

    job = enqueued_jobs.first

    expect(job[:job]).to eq LookupBookDetailsJob
    expect(job[:args]).to eq [{ "_aj_globalid" => book.to_global_id.to_s }]

    # Mock Books API volumes.list RPC method
    book_service = double

    # Mock response from call to Books API
    book_response = double(
      self_link: "https://link/to/book",
      volume_info: double(
        title: "A Tale of Two Cities",
        authors: ["Charles Dickens"],
        published_date: "1859",
        description: "A Tale of Two Cities is a novel by Charles Dickens.",
        image_links: double(thumbnail: "https://path/to/cover/image.png")
      ),
    )

    # Mock Google::Apis::BooksV1::BookService
    expect(book_service).to receive(:list_volumes).with(
      "A Tale of Two Cities", { order_by: "relevance" }
    ) { |&block| block.call(double(items: [book_response], total_items: 1), nil) }

    allow(Google::Apis::BooksV1::BooksService).to receive(:new).and_return book_service

    run_enqueued_jobs!

    expect(enqueued_jobs).to be_empty

    book = Book.find book.id
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.author).to eq "Charles Dickens"
    expect(book.published_on.to_date).to eq Date.parse("1859-01-01")
    expect(book.description).to eq "A Tale of Two Cities is a novel by Charles Dickens."
    expect(book.image_url).to eq "https://path/to/cover/image.png"
  end

  it "book details are only looked up when fields are blank"

end

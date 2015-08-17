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

  # Alternatively, faraday can be mocked.
  # HTTP mocking the discovery API requires a local HTTP response fixture.
  # TODO Make these doubles instead?  So then we're mixing mocking with fake classes.
  # TODO Convert OpenStructs to doubles too?
  # Ideally, this spec should demonstrate how to *cleanly* test Google::APIClient
  #
  # SEE ALSO Google API Client Faraday mocking in prototypes
  class FakeBookApi; end
  class FakeGoogleApiClient
    class FakeGoogleApiClientAuthorization
      def scope=(*args); end
      def fetch_access_token!; end
    end
    def initialize(*args); end
    def authorization=(*args); end
    def authorization; FakeGoogleApiClientAuthorization.new; end
  end

  it "book details are automatically looked up when created" do
    expect(enqueued_jobs).to be_empty

    book = Book.create title: "A Tale of Two Cities"

    expect(book.title).to eq "A Tale of Two Cities" # test

    expect(enqueued_jobs.length).to eq 1

    job = enqueued_jobs.first

    expect(job[:job]).to eq LookupBookDetailsJob
    expect(job[:args]).to eq [{ "_aj_globalid" => book.to_global_id.to_s }]

    fake_client = FakeGoogleApiClient.new
    fake_book_api = FakeBookApi.new
    allow(Google::APIClient).to receive(:new).and_return fake_client
    allow(fake_client).to receive(:discovered_api).and_return fake_book_api
    allow(fake_book_api).to receive_message_chain(:volumes, :list).and_return "BookVolumesListMethod"
    book_response = OpenStruct.new(
      self_link: "https://link/to/book",
      volume_info: OpenStruct.new(
        title: "A Tale of Two Cities",
        authors: ["Charles Dickens"],
        image_links: OpenStruct.new(thumbnail: "https://path/to/cover/image.png")
      )
    )

    expect(fake_client).to receive(:execute).with(
      api_method: fake_book_api.volumes.list,
      parameters: { q: "A Tale of Two Cities", order_by: "relevance" }
    ).and_return(
      OpenStruct.new data: OpenStruct.new(items: [book_response])
    )

    run_enqueued_jobs!

    expect(enqueued_jobs).to be_empty

    book.reload
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.author).to eq "Charles Dickens"
    # description ?
    # publication date ?
    expect(book.image_url).to eq "https://path/to/cover/image.png"
  end

  it "book details are only looked up when fields are blank"

end

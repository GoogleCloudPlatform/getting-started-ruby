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

    run_enqueued_jobs!

    expect(enqueued_jobs).to be_empty

    # test
    book.reload
    expect(book.title).to eq "A TALE OF TWO CITIES"
  end

  it "book details are only looked up when fields are blank"

end

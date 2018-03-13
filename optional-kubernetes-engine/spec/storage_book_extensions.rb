# Copyright 2018 Google LLC
#
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
# Implements a minimal in-memory storage service.
class Book
  def self.storage_bucket
    @storage_bucket ||= FakeStorageBucket.new "fake-storage-bucket"
  end
end

class FakeStorageBucket
  def initialize name
    @name = name
    @files = {}
  end

  attr_reader :name

  def create_file tempfile, path, content_type:, acl:
    @files[path] = FakeStorageFile.new self, tempfile.read, path
  end

  def file path
    @files[path]
  end

  def delete path
    @files.delete path
    self
  end

  def files
    @files.values
  end

  def reset!
    @files = {}
    self
  end
end

class FakeStorageFile
  def initialize bucket, body, key
    @bucket = bucket
    @body = body
    @key = key
  end

  attr_reader :key
  attr_reader :body

  def public_url
    "https://#{@bucket.name}.storage.googleapis.com/#{@key}"
  end

  def delete
    @bucket.delete key
  end
end

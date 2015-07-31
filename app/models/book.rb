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

class Book < ActiveRecord::Base
  validate :title_or_author_present

  attr_accessor :cover_image

  after_create :upload_image, if: -> (book) { book.cover_image.present? }

  private

  def title_or_author_present
    if title.blank? && author.blank?
      errors.add :base, "Title or Author must be present"
    end
  end

  # [START upload]
  def upload_image
    storage = Fog::Storage.new provider: "Google"
    bucket = storage.directories.get Rails.configuration.x.fog_dir
    image = bucket.files.new key: "cover_images/#{id}/#{cover_image.original_filename}",
                             body: cover_image.read,
                             public: true
    image.save

    update image_url: image.public_url
  end
  # [END upload]
end

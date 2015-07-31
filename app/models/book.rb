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

  #
  attr_accessor :cover_image

  #
  after_create   :upload_image, if: :cover_image
  before_update  :update_image, if: :cover_image
  before_destroy :delete_image, if: :image_url

  private

  def title_or_author_present
    if title.blank? && author.blank?
      errors.add :base, "Title or Author must be present"
    end
  end

  # [START upload]
  def upload_image
    image = StorageBucket.files.new(
      key: "cover_images/#{id}/#{cover_image.original_filename}",
      body: cover_image.read,
      public: true
    )

    image.save

    update_columns image_url: image.public_url
  end
  # [END upload]

  # [START delete]
  def delete_image
    image_key = URI.parse(image_url).path.sub(%r{^/}, "")

    StorageBucket.files.new(key: image_key).destroy
  end
  # [END delete]

  # [START update]
  def update_image
    delete_image if image_url?
    upload_image
  end
  # [END update]
end

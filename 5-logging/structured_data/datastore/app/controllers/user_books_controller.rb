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

class UserBooksController < ApplicationController

  PER_PAGE = 10

  before_action :login_required

  def index
    # [START books_by_creator]
    @books, @more = Book.query creator_id: current_user.id,
                               limit: PER_PAGE,
                               cursor: params[:more]
    # [END books_by_creator]

    render "books/index"
  end

  private

  def login_required
    redirect_to root_path unless logged_in?
  end

end

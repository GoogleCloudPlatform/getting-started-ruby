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

# [START create]
class SessionsController < ApplicationController

  # Handle Google OAuth 2.0 login callback.
  #
  # GET /auth/google_oauth2/callback
  def create
    user_info = request.env["omniauth.auth"]

    user           = User.new
    user.id        = user_info["uid"]
    user.name      = user_info["info"]["name"]
    user.image_url = user_info["info"]["image"]

    session[:user] = Marshal.dump user

    redirect_to root_path
  end
# [END create]

  # [START destroy]
  def destroy
    session.delete :user

    redirect_to root_path
  end
  # [END destroy]

end

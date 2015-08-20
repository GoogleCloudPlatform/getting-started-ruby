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

require 'resque/server'

Rails.application.routes.draw do

  resources :books

  # [START routes]
  resource :session, only: [:create, :destroy]
  resources :user_books, only: [:index]

  get "/login", to: redirect("/auth/google_oauth2")
  get "/logout", to: "sessions#destroy"
  get "/auth/google_oauth2/callback", to: "sessions#create"
  # [END routes]

  get "_ah/health", to: "app_engine#health"

  root "books#index"

  mount Resque::Server.new, :at => "/resque"

end

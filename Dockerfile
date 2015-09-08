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

FROM google/ruby

RUN apt-get update && apt-get install -qy --no-install-recommends \
    libmysqlclient-dev && \
    apt-get clean

ENV RACK_ENV production
ENV APPSERVER webrick

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN ["/usr/bin/bundle", "install", "--deployment", "--without", "development:test"]
ADD . /app

EXPOSE 8080

# [START entrypoint]
ENTRYPOINT /usr/bin/bundle exec foreman start --formation "$FORMATION"
# [END entrypoint]

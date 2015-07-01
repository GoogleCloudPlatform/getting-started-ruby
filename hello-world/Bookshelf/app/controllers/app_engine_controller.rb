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

class AppEngineController < ApplicationController

  # [START health_checks]
  def health
    render text: "ok"
  end
  # [END health_checks]

  def start
    logger.info "Application start"
    head :ok
  end

  def stop
    logger.info "Application stop"
    head :ok
  end

end

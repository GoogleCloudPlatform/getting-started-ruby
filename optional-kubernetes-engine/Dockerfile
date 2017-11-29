# The Google App Engine Ruby runtime is Debian Jessie with Ruby installed
# and various os-level packages to allow installation of popular Ruby
# gems. The source is on github at:
#   https://github.com/GoogleCloudPlatform/ruby-docker
FROM gcr.io/google_appengine/ruby

# Install 2.2.3 if not already preinstalled by the base image
RUN cd /rbenv/plugins/ruby-build && \
    git pull && \
    rbenv install -s 2.2.3 && \
    rbenv global 2.2.3 && \
    gem install -q --no-rdoc --no-ri bundler --version 1.11.2
ENV RBENV_VERSION 2.2.3

# Copy the application files.
COPY . /app/

# Install required gems.
RUN bundle install --deployment && rbenv rehash

# Set environment variables.
ENV RACK_ENV=production \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

# Run asset pipeline.
RUN bundle exec rake assets:precompile

# Reset entrypoint to override base image.
ENTRYPOINT []

# Use foreman to start processes. $FORMATION will be set in the pod
# manifest. Formations are defined in Procfile.
CMD bundle exec foreman start --formation "$FORMATION"

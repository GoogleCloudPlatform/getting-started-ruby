FROM google/ruby

RUN apt-get update && apt-get install -qy --no-install-recommends \
    libmysqlclient-dev && \
    apt-get clean

ENV RACK_ENV production

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN ["/usr/bin/bundle", "install", "--deployment", "--without", "development:test"]
ADD . /app

EXPOSE 8080
CMD []
ENV APPSERVER webrick
ENTRYPOINT /usr/bin/bundle exec rackup \
    -p 8080 /app/config.ru -s $APPSERVER -E $RACK_ENV

FROM google/ruby

RUN apt-get update && apt-get install -qy --no-install-recommends \
    libmysqlclient-dev && \
    apt-get clean

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN ["/usr/bin/bundle", "install", "--deployment"]
ADD . /app

EXPOSE 8080
CMD []
ENV APPSERVER webrick
ENV RACK_ENV production
ENTRYPOINT /usr/bin/bundle exec rackup \
    -p 8080 /app/config.ru -s $APPSERVER -E $RACK_ENV

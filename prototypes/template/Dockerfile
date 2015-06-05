FROM google/ruby

#RUN /usr/bin/apt-get update && \
#    /usr/bin/apt-get install -qy --no-install-recommends libmysqlclient-dev

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN ["/usr/bin/bundle", "install", "--deployment"]
ADD . /app

EXPOSE 8080

ENV APPSERVER webrick
ENV RACK_ENV production

CMD /usr/bin/bundle exec rackup \
    -p 8080 /app/config.ru -s $APPSERVER -E $RACK_ENV

## Uncomment the line if you want to use thin.
# ENV APPSERVER thin

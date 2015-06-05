# Ruby/MySQL on Managed VMs

Simple sample of running a Hello World [rack][] application on [App Engine Managed VMs][] 
that uses [MySQL][] in some way.

Uses a custom Dockerfile based on [`google/ruby`][] image to install `libmysqlclient-dev`.

## Run locally

    $ cp database.example.yml database.yml

Configure your production and development MySQL database configuration in `database.yml`.

    $ bundle
    $ bundle exec rackup

## Run test

    $ bundle
    $ bundle exec rspec test.rb

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

## Dependencies

 - Using [rack][] for making the web application
 - Using [erb][] for HTML templating
 - Using [mysql2][] for connecting to MySQL
 - Using [sequel][] for light-weight SQL database operations
 - Using [rspec][] testing framework
 - Using [capybara][] acceptance testing framework

[rack]: http://rack.github.io/
[MySQL]: https://www.mysql.com/
[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby]: https://registry.hub.docker.com/u/google/ruby/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[health check requests]: https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#health_check_requests
[rack]: http://rack.github.io/
[erb]: http://ruby-doc.org/stdlib-2.2.2/libdoc/erb/rdoc/ERB.html
[mysql2]: https://github.com/brianmario/mysql2
[sequel]: https://github.com/jeremyevans/sequel
[rspec]: http://rspec.info/
[capybara]: http://jnicklas.github.io/capybara/

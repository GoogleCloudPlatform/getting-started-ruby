# Bookshelf

Checkout branches to view particular steps of this sample application.

 - `1-hello-world`
 - `2-sql`
 - `2-datastore`
 - `3-binary-data`
 - `4-authentication`
 - `5-logging`
 - `6-task-queue`
 - `7-compute-engine`

## Structured Data: SQL with ActiveRecord

### Run

To run the application, first install dependencies:

    $ bundle install

To setup the database for local development, copy the sample `database.yml` file:

    $ cp config/database.example.yml config/database.yml

By default, sqlite is used.  You can edit the `database.yml` to customize your database.

To create the database and run migrations to create the required tables, run:

    $ rake db:migrate

Then, run the Rails web server:

    $ rails server

### To run the tests

    $ bundle install
    $ rake db:test:prepare
    $ bundle exec rspec spec/

### To deploy to App Engine Managed VMs

    $ gcloud preview app deploy app.yaml --set-default

This application uses a custom `Dockerfile` based on the [`google/ruby`][] image
to install dependencies required for the MySQL gem to run.

The `Dockerfile` also runs `bundle install --without development:test` so that only
production gems will be installed in production.

[google/ruby]: https://registry.hub.docker.com/u/google/ruby-runtime/

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

* See [LICENSE](LICENSE)

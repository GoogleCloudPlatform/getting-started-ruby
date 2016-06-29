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

    $ gcloud app deploy

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

* See [LICENSE](LICENSE)

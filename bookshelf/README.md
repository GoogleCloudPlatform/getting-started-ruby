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

## User Authentication using Google OAuth

### Run

To run the application, first install dependencies:

    $ bundle install

To setup the database for local development, copy the sample `database.yml` file:

    $ cp config/secrets.example.yml config/secrets.yml

Edit `secrets.yml` and add your `client_id` and `client_secret` from your project's
web application credentials ([console](https://pantheon.corp.google.com/project/_/apiui/credential)).

Then, run the Rails web server:

    $ rails server

### To run the tests

    $ bundle install
    $ bundle exec rspec spec/

### To deploy to App Engine Managed VMs

    $ gcloud preview app deploy app.yaml --set-default

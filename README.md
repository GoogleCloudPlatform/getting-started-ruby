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

  * In the Developers Console, go to "APIs & auth" -> "Credentials"
  * "Add credentials" then "OAuth 2.0 client ID"
  * Select "Web application"
  * Follow instructions to setup consent screen if prompted
  * Authorized redirect URIs:
    * http://localhost:3000/auth/google_oauth2/callback
    * http://<project-id>/auth/google_oauth2/callback
  * Copy your client id and secret for below:

  * In the Developers Console, go to "APIs & auth" -> "APIs"
  * "Google+ API"
  * Enable

Edit `secrets.yml` and add your `client_id` and `client_secret` from your project's
web application credentials ([console](https://pantheon.corp.google.com/project/_/apiui/credential)).

Then, run the Rails web server:

    $ rails server

### To run the tests

    $ bundle install
    $ bundle exec rspec spec/

### To deploy to App Engine Managed VMs

    $ gcloud preview app deploy app.yaml --set-default

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

<<<<<<< HEAD
=======
[google/ruby]: https://registry.hub.docker.com/u/google/ruby-runtime/

## Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

>>>>>>> 3-cloud-storage
## Licensing

* See [LICENSE](LICENSE)

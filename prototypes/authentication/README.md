# Google OAuth 2 Authentication

Simple [Sinatra][] application that provides [Google login][] via OAuth 2.0.

Uses `omniauth` gem and `omniauth-google-oauth2` plugin for authentication.

Uses the the [`google/ruby-runtime`][] Docker image with no customization.

Added App Engine [health check requests][].

## Run locally

 - Create a Client ID for your web application under [APIs & auth > Credentials][creds]
   - Configure *JavaScript origins*: `http://localhost:9292` and `https://<project ID>.appspot.com`
   - Configure *Redirect URIs*: `http://localhost:9292/auth/google_oauth2/callback` and `https://<project ID>.appspot.com/auth/google_oauth2/callback`
 - Edit `authentication.yml` and add your `Client ID` and `Client secret`

Then run the application:

    $ bundle
    $ bundle exec rackup

## Run tests

    $ bundle exec rspec test.rb

## Deploy

    $ gcloud config set project <PROJECT_ID>
    $ gcloud preview app deploy app.yaml --set-default

[App Engine Managed VMs]: https://cloud.google.com/appengine/docs/managed-vms/
[google/ruby-runtime]: https://registry.hub.docker.com/u/google/ruby-runtime/
[health check requests]: https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#health_check_requests
[creds]: https://pantheon.corp.google.com/project/_/apiui/credential
[Sinatra]: http://www.sinatrarb.com/
[Google login]: https://developers.google.com/identity/protocols/OpenIDConnect

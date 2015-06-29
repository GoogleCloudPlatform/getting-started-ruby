# Ruby Hello World

## Run the app on your local computer

1. Install dependencies. Enter the following command:

    $ bundle install

2. Start the application:

    $ bundle exec rackup -p 8080

Unlike Node.js, the port is not defined in the application code but via the
command-line instead.

## Dockerfile

[`google/ruby-runtime`](https://registry.hub.docker.com/u/google/ruby-runtime/)

 - Requires a `Gemfile` file declaring application dependencies
 - Requires a `config.ru` rackup file defining your web application

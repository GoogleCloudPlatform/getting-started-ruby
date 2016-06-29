# Bookshelf

Checkout branches to view particular steps of this sample application.

 - `1-hello-world`
 - `2-sql`
 - `2-datastore`
 - `3-cloud-storage`
 - `4-authentication`
 - `5-logging`
 - `6-task-queue`
 - `7-compute-engine`

## 3: Use Cloud Storage

### Setup Google Cloud Storage

Pick a bucket name, it must be globally unique. Replace `<bucket>`
below with this name. We will create it, and make it globally
readable with A or B:

A. Command line

    $ gsutil mb gs://<bucket>
    $ gsutil defacl set public-read gs://<bucket>

B. Web UI

  1. Click "Storage -> Cloud Storage -> Browser" in the left side tree
  2. Click the blue "Create bucket" button
  3. Type in the name you picked, click "Create"
  4. Click on "Buckets" to return to the top level
  5. On the right of the line of your new bucket, click the three
     dots, then "Edit object default permissions"
  6. Click "+ Add item"
  7. Under ENTITY select "User", Under NAME enter "allUsers", under
     ACCESS leave it as Reader.
  8. Click the blue "Save" button.

Open `config/application.rb`, edit the below line to replace `bucket`
with the name of your bucket:

    config.x.fog_dir = 'bucket'

#### Setup your cloud storage secrets

In the Web UI:

  1. Click "Storage -> Cloud Storage -> Settings" in the left side tree
  2. Select the "Interoperability" tab
  3. Click the "Create a new key" button

Setup the secrets file:

    $ cp config/fog_credentials.example.yml config/fog_credentials.yml

Edit `fog_credentials.yml` and add your secrets from the Web UI.

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

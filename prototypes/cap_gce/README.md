Get app running locally
=======================

Don't: install postgress, we'll use sqlite for local development

* Install ruby and gem, as specific to your OS.
  * (15.04) sudo apt-get install ruby
* Also install ruby dev libs, to be able to build gems with native extensions
  * (15.04) sudo apt-get install ruby-dev build-essential

  I like to set GEM_HOME to $HOME/.gem
  and then add $GEM_HOME/bin to PATH

* (15.04) more -dev needed for gems: libxml2-dev zlib1g-dev libsqlite3-dev libpq-dev

Install bundler and rails
```
$ gem install bundler
$ gem install rails
```

  note: Use rvm or rbenv if you're used to it

git clone this app, then run:
```
$ bundle install
$ bundle exec rake db:migrate
$ rails s
```

check that it is working locally, goto localhost:3000/todos

Intermetiate step
-----------------

Configure your config/database.yml to point to the databse of your
choice from previous step:

* Google Cloud SQL
* Postgres Click-to-Deploy VM

You can configure for only production, or for local dev too

Push your app code to your github repo
In "Developers Console" see "Source Code", click on gear
```
gcloud auth login
gcloud init <projectID>
cd <projectID>/default
git push -u origin master
```
OR:
```
git config credential.helper gcloud.sh ???
git remote add cloud https://source.developers.google.com/p/<ProjectID>/
git push cloud master:rails-todos
```


Create your GCE VM for your app
-------------------------------

Use the web interface to create a new vm, OR:
```
gcloud compute instances create rails-app --image ubuntu-15-04 --scopes https://www.googleapis.com/auth/projecthosting --tags http-server
```
other scopes probably needed: storage-full, logging-write, datastore, userinfo-email?

Click the SSH button, OR:
```
gcloud compute ssh rails-app
```

Install stuff:

```
sudo apt-get install -y ruby-dev build-essential libxml2-dev zlib1g-dev libsqlite3-dev nginx libpq-dev
sudo gem install rails bundler
mkdir $HOME/rails-app
ls -d $HOME/rails-app
exit
```

edit config/deploy.rb, change
```
set :repo_url, 'https://source.developers.google.com/p/<projectID>'
```
to point to your git repo

set
```
set :branch, 'rails-todos'
```
If using a particluar branch

edit config/deploy/production
add the ip and user of your gce vm:
```
server '104.197.46.193', user: 'jeffmendoza', roles: %w{app web}
```

bundle exec cap produciton setup
bundle exec cap produciton setup:upload_yml
bundle exec cap produciton deploy:check
bundle exec cap produciton deploy

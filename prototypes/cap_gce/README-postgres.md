goto
https://cloud.google.com/launcher

search for 'postgres'

select 'PostgreSQL' from Bitnami

click 'Get Started'

select your project (same that rails app will be in)

select zone, machine type

click 'create'

copy username / password

click 'Manage the VM instance'

copy the 'Internal IP'

I got:

lp: postgres/eoW1W1ZE
internal: 10.240.234.0

edit your config/database.yml, change production to be:

production:
  adapter: postgresql
  database: rails-prod
  username: postgres
  password: eoW1W1ZE
  host: 10.240.234.0

run:

bundle exec rake db:migrate RAILS_ENV=production
bundle exec rake db:create RAILS_ENV=production


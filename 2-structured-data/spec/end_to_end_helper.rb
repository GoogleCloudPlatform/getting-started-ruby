require File.expand_path("../../../spec/e2e", __FILE__)

$end_to_end_test_setup_complete = false

# Set up database.yml with database configuration for end-to-end
# tests with values from environment variables
def configure_end_to_end config
  config.before :each, :e2e do
    unless $end_to_end_test_setup_complete
      database_yml = File.expand_path("../../config/database.yml", __FILE__)
      database_configuration = File.read database_yml

      configuration_variables = {
        "your-mysql-user-here"         => "MYSQL_USER",
        "your-mysql-password-here"     => "MYSQL_PASSWORD",
        "your-mysql-IPv4-address-here" => "MYSQL_HOST",
        "your-mysql-database-here"     => "MYSQL_DATABASE"
      }

      configuration_variables.each do |key, env_var|
        raise "Please set environment variable #{env_var}" unless ENV[env_var]

        database_configuration.sub! key, ENV[env_var]
      end

      File.write database_yml, database_configuration

      $end_to_end_test_setup_complete = true
    end
  end
end

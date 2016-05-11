Rails.configuration.x.fog_dir = "testbucket"

def configure_storage config
  config.before :each do
    Fog::Mock.reset
    FogStorage.directories.create key: "testbucket", acl: "public-read"
  end
end

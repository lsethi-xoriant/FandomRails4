require "yaml"

module CliUtils
  def get_deploy_settings
    deploy_settings_filename = "#{File.dirname(__FILE__)}/../config/deploy_settings.yml"
    YAML.load_file(deploy_settings_filename)
  end
  
  def db_connect(config)
    field_map = {
      host: 'host',
      dbname: 'database',
      user: 'username',
      password: 'password',
      port: 'port'
    }
    pg_config = {}
    field_map.each do |k, v|
      if config.key? v
        pg_config[k] = config[v]
      end
    end
    PG::Connection.new(pg_config)
  end

  def get_s3_bucket(s3_settings) 
    s3 = AWS::S3.new(
      access_key_id: s3_settings[:access_key_id],
      secret_access_key: s3_settings[:secret_access_key],
      s3_endpoint: s3_settings[:s3_endpoint]
    )
    bucket = s3.buckets[s3_settings[:bucket]]
    return bucket 
  end
  
end
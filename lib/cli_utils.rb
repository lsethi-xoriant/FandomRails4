require "yaml"

module CliUtils
  def get_deploy_settings
    deploy_settings_filename = "#{File.dirname(__FILE__)}/../config/deploy_settings.yml"
    YAML.load_file(deploy_settings_filename)
  end
end
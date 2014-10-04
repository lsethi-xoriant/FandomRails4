require('yaml')
require('aws/ses')

# Script entry point.
def main
  if ARGV.size != 1
    puts <<-EOF
Usage: #{$0} <rails app dir>
  Checks wheter error log files have been created, and send a notification if they have. 
  Should be run by cron.
EOF
    exit
  end
  
  rails_app_dir = ARGV[0]

  deploy_settings = YAML.load_file("#{rails_app_dir}/config/deploy_settings.yml")
  ses = configure_ses(deploy_settings)  
  from = deploy_settings['mailer']['default_from']
  to = deploy_settings['mailer']['shado_monitoring_address']
  hostname = Socket.gethostbyname(Socket.gethostname).first
  if Dir["#{rails_app_dir}/log/events/*close*.log"].any?
    ses.send_email(
     :to        => [to],
     :source    => from,
     :subject   => "Error logs have been created on #{hostname}",
     :html_body => <<-EOF
This is automatically generated message. 

Error logs have been created on #{hostname}; this means that the log daemon could not handle some closed log file.
If no action will be taken, the log files will be lost forever as soon as the machine is terminated.

EOF
    )
  end
end

def configure_ses(deploy_settings)
  ses = AWS::SES::Base.new(
    :access_key_id     => deploy_settings['aws']['access_key_id'], 
    :secret_access_key => deploy_settings['aws']['secret_access_key']
  )
  ses
end


main()

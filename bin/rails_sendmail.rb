require('yaml')
require('aws/ses')

# Script entry point.
def main
  if ARGV.size != 3
    puts <<-EOF
Usage: #{$0} <rails app dir> <to> <subject>
  Send the standard input by email, using the rails mailer configuration.
  <to> can contained multiple addresses, separated by comma.
  Currently only AWS SES is supported. 
EOF
    exit
  end
  
  rails_app_dir = ARGV[0]
  to = ARGV[1]
  subject = ARGV[2]

  ses, from = configure_ses(rails_app_dir)  
  send_email(ses, from, to, subject)
end

def configure_ses(rails_app_dir)
  deploy_settings = YAML.load_file("#{rails_app_dir}/config/deploy_settings.yml")
  ses = AWS::SES::Base.new(
    :access_key_id     => deploy_settings['mailer']['ses'][:access_key_id], 
    :secret_access_key => deploy_settings['mailer']['ses'][:secret_access_key]
  )
  [ses, deploy_settings['mailer']['default_from']]
end

def send_email(ses, from, to, subject)
  ses.send_email(
   :to        => to.split(','),
   :source    => from,
   :subject   => subject,
   :html_body => STDIN.read
  )
end


main()

require('csv')
require('aws/ses')
require_relative('../lib/config_utils')
include ConfigUtils

# Sends a newsletter to the users listed in a CSV. 
# For further information please see the documentation of the command line tool.
def send_newsletter(rails_app_dir, tenant, html_template_path, csv_path, from_email, subject)
  settings = YAML.load_file("#{rails_app_dir}/config/deploy_settings.yml")

  ses = AWS::SES::Base.new(
    :access_key_id     => get_from_hash_by_path(settings, "sites/#{tenant}/mailer/ses/:access_key_id", nil),
    :secret_access_key => get_from_hash_by_path(settings, "sites/#{tenant}/mailer/ses/:secret_access_key", nil),
    :server => get_from_hash_by_path(settings, "sites/#{tenant}/mailer/ses/:server", nil)
  )

  csv = CSV.read(csv_path, :col_sep => "\t")
  html_template = open(html_template_path).read
  
  keys = csv[0]
  users = get_users(csv[1 .. -1], keys)
  users.each do |user|
    send_newsletter_to_user(user, html_template, ses, from_email, subject)
  end
end

def get_users(rows, keys)
  rows.map do |values|
    Hash[*(keys.zip values).flatten]
  end
end

def send_newsletter_to_user(user, html, ses, from_email, subject)
  begin
    email = user["email"]
    user.each do |k, v|
      html.gsub!("$" + k, v)
    end
    puts_no_newline "sending the newsletter to email #{email}... "
    ses.send_email(
     :to        => [email],
     :source    => from_email,
     :subject   => subject,
     :html_body => html
    )
    puts "done."
  rescue Exception => e
    puts "error: #{e}"
  end
end

def puts_no_newline(msg)
  print msg
  $stdout.flush
end

# Script entry point.
def main
  if ARGV.size != 6
    puts <<-EOF
Usage: #{$0} <rails_app_dir> <tenant> <html_template> <csv> <from_email> <subject>
  Send a newsletter to every used listed in <csv>.
  The csv separator is TAB, the header line is mandatory and a the newsletter is sent to every used listed in the 'email' column.
  The rails_app_dir and the tenant are used to set the smtp configuration.
EOF
    exit
  end
  
  rails_app_dir  = ARGV[0]
  tenant  = ARGV[1]
  html_template_path = ARGV[2]
  csv_path = ARGV[3]
  from_email = ARGV[4]
  subject = ARGV[5]
  
  send_newsletter(rails_app_dir, tenant, html_template_path, csv_path, from_email, subject)
end

main()

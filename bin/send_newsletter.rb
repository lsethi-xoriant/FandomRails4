require('csv')
require('aws/ses')

# Sends a newsletter to the users listed in a CSV. 
# For further information please see the documentation of the command line tool.
def send_newsletter(csv_path, html_template_path, ses_access_key_id, ses_secret_key, from_email, subject)
  csv = CSV.read(csv_path, :col_sep => "\t")
  html_template = open(html_template_path).read
  ses = AWS::SES::Base.new(
    :access_key_id     => ses_access_key_id, 
    :secret_access_key => ses_secret_key
  )
  
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
  email = user["email"]
  user.each do |k, v|
    html.gsub!("$" + k, v)
  end
  puts "sending the newsletter to email #{email}..."
  ses.send_email(
   :to        => [email],
   :source    => from_email,
   :subject   => subject,
   :html_body => html
  )
end


# Script entry point.
def main
  if ARGV.size < 6
    puts <<-EOF
Usage: #{$0} <html_template> <csv> <ses_access_key_id> <ses_secret_key> <from_email> <subject>
  Send a newsletter to every used listed in <csv>.
  The csv separator is TAB, the header line is mandatory and a the newsletter 
  is sent to every used listed in the email column.
EOF
    exit
  end
  
  html_template_path = ARGV[0]
  csv_path = ARGV[1]
  ses_access_key_id  = ARGV[2]
  ses_secret_key = ARGV[3]
  from_email = ARGV[4]
  subject = ARGV[5]
  
  send_newsletter(csv_path, html_template_path, ses_access_key_id, ses_secret_key, from_email, subject)
end

main()

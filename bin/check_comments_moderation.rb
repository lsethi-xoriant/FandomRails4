require "pg"
require "yaml"
require "logger"
require "aws/ses"
require "active_support/time"

def main

  if ARGV.size != 1
    puts <<-EOF
      This script sends an email if no moderation have been executed on comments for a certain amount of hours
      Usage: #{$0} <config.yml>
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)
  rails_app_dir = config["rails_app_dir"]
  tenant = config["tenant"]
  tolerance_threshold = config["tolerance_threshold"]

  ses, mail_from = configure_ses(rails_app_dir, config)
  mail_to = config["to"]
  mail_subject = config["subject"]

  conn = PG::Connection.open(config["db"])

  logger = Logger.new("#{rails_app_dir}/log/check_comments_moderation_logs.log")

  start_time = Time.now
  logger.info("starting comments moderation check process")

  if tenant
    conn.exec("SET search_path TO '#{tenant}';")
  end

  logger.info("retrieving last user_comment_interactions updated_at")
  updated_at_start_time = Time.now

  max_updated_at = conn.exec("SELECT MAX(updated_at) FROM user_comment_interactions WHERE approved IS NOT NULL;").first["max"]

  logger.info("last user_comment_interactions updated_at is #{max_updated_at}; retrieved in #{Time.now - start_time} seconds")

  hours_lapsed = (Time.now - Time.parse(max_updated_at)).to_i / 1.hours

  logger.info("#{hours_lapsed} hours lapsed since last moderation")

  if hours_lapsed > tolerance_threshold
    body = "Non c'è stata moderazione su #{tenant} nelle ultime #{hours_lapsed} ore (la soglia è di #{tolerance_threshold} ore)."
    send_email(ses, mail_from, mail_to, mail_subject, body)
    logger.info("email(s) sent (tolerance threshold: #{tolerance_threshold} hours)")
  end

  logger.info("comments moderation check ended in #{Time.now - start_time} seconds")

end

def configure_ses(rails_app_dir, config)
  ses = AWS::SES::Base.new(
    :access_key_id     => config['ses'][:access_key_id], 
    :secret_access_key => config['ses'][:secret_access_key]
  )
  [ses, config['default_from']]
end

def send_email(ses, from, to, subject, body)
  ses.send_email(
    :to        => to.split(","),
    :source    => from,
    :subject   => subject,
    :html_body => body
  )
end

main()
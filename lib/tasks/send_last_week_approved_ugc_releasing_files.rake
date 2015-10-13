#!/bin/env ruby
# encoding: utf-8

require 'rake'

desc "Send to a list of email addresses a random selection of releasing files for user cta approved in the last 'days' days for selected tenant"

task :send_releasing_files, [:tenant, :emails, :days, :max_releasing_files] => :environment do |t, args|
  send_releasing_files(args[:tenant], args[:emails], args[:days], args[:max_releasing_files])
end

def send_releasing_files(tenant, emails, days, max_releasing_files)

  switch_tenant(tenant)
  days = days.to_i

  user_call_to_actions = CallToAction.where("user_id IS NOT NULL AND approved = true AND updated_at >= ?", Date.today - days.days)
  user_call_to_actions_count = user_call_to_actions.count
  releasing_files_number = [user_call_to_actions_count, max_releasing_files.to_i].min

  puts "#{ user_call_to_actions_count } approved user_call_to_actions updated in the last #{ days } days."
  puts "Creating body mail for #{ releasing_files_number } of these..."

  releasing_files_text = 
    "<br/>
    <table style='width:100%'>
      <tr>
        <td><b> Call to action slug </b></td><td><b> Link alla liberatoria </b></td>
      </tr>"

  user_call_to_actions.sample(releasing_files_number).each do |user_call_to_action|
    releasing_files_text << 
      "<tr>
        <td> #{user_call_to_action.slug} </td>
        <td> #{user_call_to_action.releasing_file ? user_call_to_action.releasing_file.file.url : "Liberatoria non presente"} </td>
      </tr>"
  end
  releasing_files_text << "</table>"

  body = "<h3>Negli ultimi #{ days } giorni sono state approvate #{ user_call_to_actions_count } call to action utente.</h3><br/>"
  if user_call_to_actions_count > releasing_files_number
    body << "A seguire, un campione di #{ releasing_files_number } di essi:<br/>"
  end
  body << releasing_files_text

  SystemMailer.send_approved_comments_mail(emails, tenant, days, body, "Report call to action utente approvate negli ultimi #{ days } giorni su #{ tenant.capitalize }").deliver
  puts "Mails sent."

end
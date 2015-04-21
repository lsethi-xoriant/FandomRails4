#!/bin/env ruby
# encoding: utf-8

require 'rake'

desc "Send to a list of email addresses a random selection of 'max_comments' updated in the last 'days' days for selected tenant"

task :send_approved_comments, [:tenant, :emails, :days, :max_comments] => :environment do |t, args|
  send_approved_comments(args[:tenant], args[:emails], args[:days], args[:max_comments])
end

def send_approved_comments(tenant, emails, days, max_comments)

  switch_tenant(tenant)
  days = days.to_i
  user_comment_interactions = UserCommentInteraction.where("approved = true AND updated_at >= ?", Date.today - days.days)
  user_comment_interactions_count = user_comment_interactions.count
  comments_number = [user_comment_interactions_count, max_comments.to_i].min

  puts "#{ user_comment_interactions_count } user_comment_interactions updated in the last #{ days } days."
  puts "Creating body mail for #{ comments_number } of these..."

  comments_text = 
    "<br/>
    <table style='width:100%'>
      <tr>
        <td><b> Creato il </b></td><td><b> Aggiornato il </b></td><td><b> Call to action slug </b></td><td><b> Testo </b></td>
      </tr>"

  user_comment_interactions.sample(comments_number).each do |user_comment_interaction|
    interaction_id = Interaction.where(:resource_type => "Comment", :resource_id => user_comment_interaction.comment_id).first.call_to_action_id
    call_to_action_slug = CallToAction.find(interaction_id).slug
    comments_text << 
      "<tr>
        <td> #{user_comment_interaction.created_at.in_time_zone(USER_TIME_ZONE).strftime('%d/%m/%Y, ore %H:%M')} </td>
        <td> #{user_comment_interaction.updated_at.in_time_zone(USER_TIME_ZONE).strftime('%d/%m/%Y, ore %H:%M')} </td>
        <td> #{call_to_action_slug} </td>
        <td> #{user_comment_interaction.text} </td>
      </tr>"
  end
  comments_text << "</table>"

  body = "<h3>Negli ultimi #{ days } giorni sono stati approvati #{ user_comment_interactions_count } commenti.</h3><br/>"
  if user_comment_interactions_count > comments_number
    body << "A seguire, un campione di #{ comments_number } di essi:<br/>"
  end
  body << comments_text

  SystemMailer.send_approved_comments_mail(emails, tenant, days, body).deliver
  puts "Mails sent."

end
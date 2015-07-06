#!/bin/env ruby
# encoding: utf-8

namespace :instantwin_braun do

  desc "Generates all instantwins entries for Braun having prize winning date and time"

  task :generate_instantwins => :environment do
    generate_braun_instantwins()
  end

  def generate_braun_instantwins
    switch_tenant("braun_ic")

    contest_call_to_action = CallToAction.find_by_name('instantwin-call-to-action')
    instantwin_interaction_id = contest_call_to_action.interactions.where(:resource_type => "InstantwinInteraction").first.resource_id

    # Idempotent
    instantwins_deleted = Instantwin.delete_all("instantwin_interaction_id = #{instantwin_interaction_id}")
    if instantwins_deleted > 0
      interaction = Interaction.where("resource_type = 'Instantwin' AND resource_id = #{instantwin_interaction_id}").first
      user_interactions_deleted = interaction ? UserInteraction.delete_all("interaction_id = #{ interaction.id }") : 0
      puts "#{instantwins_deleted} instantwins and #{user_interactions_deleted} user interactions referring to instantwin interaction with ID #{instantwin_interaction_id} deleted"
    end

    contest_start_datetime = contest_call_to_action.valid_from.to_datetime
    contest_end_datetime = contest_call_to_action.valid_to.to_datetime
    reward_id = Reward.find_by_name('minipimer').id

    prize_start_date = contest_start_datetime.in_time_zone("Rome").to_date
    prize_counter = 1

    instantwins_to_be_created = (contest_end_datetime - contest_start_datetime).to_i + 1

    start_time = Time.now
    puts "#{instantwins_to_be_created} instantwins to be created \nStart time: #{start_time}"
    STDOUT.flush

    while prize_start_date <= contest_end_datetime

      hour = get_start_hour_for_instantwin(prize_start_date, contest_call_to_action)
      time = "#{hour}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} Rome"
      win_time = Time.parse(prize_start_date.strftime("%Y-%m-%d") + " " + time)
      win_time_end = win_time.end_of_day
      unique_id = Digest::MD5.hexdigest("#{prize_counter}")

      while Instantwin.where("(reward_info->>'prize_code') = ?", unique_id).present?
        prize_counter += 1
        unique_id = Digest::MD5.hexdigest("#{prize_counter}")
      end

      reward_info = { 
        :reward_id => reward_id, 
        :prize_code => unique_id
      }.to_json

      instantwin = Instantwin.create(
        :valid_from => win_time,
        :valid_to => win_time_end,
        :won => false,
        :instantwin_interaction_id => instantwin_interaction_id,
        :reward_info => reward_info
      )

      if (prize_counter % 5000) == 0
        puts "#{prize_counter} / #{instantwins_to_be_created} instantwins created in #{ Time.now - start_time } seconds"
        STDOUT.flush
      end

      prize_start_date += 1.day
      prize_counter += 1

    end

    puts "All instantwins created in #{ Time.now - start_time } seconds\n"

  end

  def get_start_hour_for_instantwin(date, contest_call_to_action)
    if(date == contest_call_to_action.valid_from.to_date)
      hour = (contest_call_to_action.valid_from.hour.to_i..23).to_a.sample
    elsif(date == contest_call_to_action.valid_to.to_date)
      hour = (0..contest_call_to_action.valid_to.hour.to_i).to_a.sample
    else
      hour = (0..23).to_a.sample
    end
  end

end
#!/bin/env ruby
# encoding: utf-8

# require 'byebug'

INTERVAL_WIN_SECONDS = 10 * 60 # 10 minutes
WIN_PRIZE_SECONDS = 10 * 60 # 10 minutes

namespace :instantwin_demo do

  desc "Generates all instantwins entries (one every 5 minutes) having prize winning date and time"

  task :generate_instantwins => :environment do
    generate_instantwins()
  end

  def generate_instantwins
    switch_tenant("fandom")

    contest_call_to_action = CallToAction.find_by_name('instantwin-call-to-action')
    instantwin_interaction_id = contest_call_to_action.interactions.where(:resource_type => "InstantwinInteraction").first.resource_id

    # Idempotent
    instantwins_deleted = Instantwin.delete_all("instantwin_interaction_id = #{instantwin_interaction_id}")
    if instantwins_deleted > 0
      interaction = Interaction.where("resource_type = 'Instantwin' AND resource_id = #{instantwin_interaction_id}").first
      user_interactions_deleted = interaction ? UserInteraction.delete_all("interaction_id = #{ interaction.id }") : 0
      puts "#{ instantwins_deleted } instantwins and #{ user_interactions_deleted } user interactions referring to instantwin interaction with ID #{ instantwin_interaction_id } deleted"
    end

    contest_start_datetime = contest_call_to_action.valid_from.to_datetime
    contest_end_datetime = contest_call_to_action.valid_to.to_datetime
    reward_id = Reward.find_by_name('demo-instantwin-reward').id

    prize_start_datetime = contest_start_datetime
    prize_counter = 1

    instantwins_to_be_created = ((contest_end_datetime - contest_start_datetime).to_i * 24 * 60 * 60) / INTERVAL_WIN_SECONDS

    start_time = Time.now
    puts "#{ instantwins_to_be_created } instantwins to be created \nStart time: #{start_time}"
    STDOUT.flush

    while prize_start_datetime <= contest_end_datetime

      win_time = prize_start_datetime + (0..(INTERVAL_WIN_SECONDS - 1)).to_a.sample.seconds
      win_time_end = win_time + WIN_PRIZE_SECONDS.seconds # time to win the prize
      prize_end_datetime = prize_start_datetime + (INTERVAL_WIN_SECONDS - 1).seconds
      unique_id = Digest::MD5.hexdigest("#{ prize_counter }")

      while Instantwin.where("(reward_info->>'prize_code') = ?", unique_id).present?
        prize_counter += 1
        unique_id = Digest::MD5.hexdigest("#{ prize_counter }")
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
        puts "#{ prize_counter } / #{ instantwins_to_be_created } instantwins created in #{ Time.now - start_time } seconds"
        STDOUT.flush
      end

      prize_start_datetime = prize_end_datetime + 1.seconds
      prize_counter += 1

    end

    puts "All instantwins created in #{ Time.now - start_time } seconds\n"

  end

end
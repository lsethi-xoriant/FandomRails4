  class UserCounter < ActiveRecord::Base
  attr_accessible :name, :user_id, :counters

  belongs_to :user

  def self.update_counters(interaction, user_interaction, user, unique_and_all)
    resource_type = interaction.resource_type.downcase
    if resource_type == "quiz"
      quiz_type = interaction.resource.quiz_type.downcase
    end

    ["DAILY", "TOTAL"].each do |periodicity|
      user_counter = find_or_create_user_counter_by_perodicity(user, periodicity)
      counters = JSON.parse(user_counter.counters) 

      counters = update_counter_by_periodicity_and_counter_type(counters, "all", interaction, user_interaction, quiz_type)

      if unique_and_all
        counters = update_counter_by_periodicity_and_counter_type(counters, "unique", interaction, user_interaction, quiz_type)
      end

      user_counter.assign_attributes(counters: counters.to_json) 
      user_counter.save   
    end
  end

  def self.update_counter_by_periodicity_and_counter_type(counters, counter_type, interaction, user_interaction, quiz_type)  
    counter_name = "#{counter_type}_#{interaction.resource_type}".upcase
    counters = update_counter(counters, counter_name)

    if quiz_type
      counter_name = "#{counter_type}_#{quiz_type}".upcase
      counters = update_counter(counters, counter_name)

      if quiz_type == "trivia" && user_interaction.answer.correct
        counter_name = "#{counter_name}_correct_answer".upcase
        counters = update_counter(counters, counter_name)
      end
    end
    counters
  end

  def self.find_or_create_user_counter_by_perodicity(user, periodicity)
    user_counter = user.user_counters.find_by_name(periodicity)
    if user_counter
      if periodicity == "DAILY" && (user_counter.updated_at.strftime("%d") != DateTime.now.utc.strftime("%d"))
        user_counter.assign_attributes(counters: "{}")
      end
      user_counter
    else
      UserCounter.new(user_id: user.id, name: periodicity, counters: "{}")
    end
  end

  def self.update_counter(user_counters, counter_name)  
    if user_counters[counter_name]
      user_counters[counter_name] += 1
    else
      user_counters[counter_name] = 1
    end     
    user_counters
  end

  def self.get_by_user(user)
    # TODO: periodicity is hardcoded
    if user.mocked?
      { "DAILY" => get_mocked_counters(), "TOTAL" => get_mocked_counters() }
    else
      result = {}
      user.user_counters.map do |counter|
        result[counter.name] = JSON.parse(counter.counters)
      end
      result
    end
  end
  
  def get_mocked_counters
    result = {}
    COUNTER_NAMES.each do |name|
      result[name] = 0
    end
    result
  end
end

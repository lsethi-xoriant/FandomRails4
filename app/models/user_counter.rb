  class UserCounter < ActiveRecord::Base
  attr_accessible :name, :user_id, :counters

  belongs_to :user

  def self.update_unique_counters(user_interaction, user)
    update_counters(user_interaction, user, "unique")
  end

  def self.update_all_counters(user_interaction, user)
    update_counters(user_interaction, user, "all")
  end

  def self.update_counters(user_interaction, user, counter_type)
    resource_type = user_interaction.interaction.resource_type.downcase

    counter_name = "#{counter_type}_#{user_interaction.interaction.resource_type}".upcase
    update_counters_in_all_periodicities(user, counter_name)

    if resource_type == "quiz"
      counter_name = "#{counter_type}_#{user_interaction.interaction.resource.quiz_type}".upcase

      quiz_type = user_interaction.interaction.resource.quiz_type.downcase
      if quiz_type == "trivia" && user_interaction.answer.correct
        update_counters_in_all_periodicities(user, "#{counter_name}_correct_answer".upcase)
      end
      update_counters_in_all_periodicities(user, counter_name)
    end
  end

  def self.update_counters_in_all_periodicities(user, counter_name)
    update_counter(user, counter_name, "TOTAL")
    update_counter(user, counter_name, "DAILY")
  end

  def self.update_counter(user, counter_name, name)
    user_counter = user.user_counters.find_by_name(name)
    if user_counter
      user_counters = JSON.parse(user_counter.counters) 
      if name == "DAILY" && (user_counter.updated_at.strftime("%d") != DateTime.now.utc.strftime("%d"))
        user_counters[counter_name] = 1
      else 
        if user_counters[counter_name]
          user_counters[counter_name] += 1
        else
          user_counters[counter_name] = 1
        end
      end
      user_counter.update_attribute(:counters, user_counters.to_json)
    else
      counters = { "#{counter_name}" => 1 }
      user_counter = UserCounter.create(user_id: user.id, name: name, counters: counters.to_json)
    end
  end

  def self.get_by_user(user)
    result = {}
    user.user_counters.map do |counter|
      result[counter.name] = JSON.parse(counter.counters)
    end
    result
  end
end

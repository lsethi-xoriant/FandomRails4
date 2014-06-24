  class UserCounter < ActiveRecord::Base
  attr_accessible :name, :user_id, :correct_answer, :play

  belongs_to :user

  def self.update_counters(user_interaction, user)
    if(user_interaction.answer && user_interaction.is_answer_correct?)
      update_correct_answer_counter(user) 
    end
  end

  def self.update_correct_answer_counter(user)
    update_correct_answer_by_name(user, "TOTAL")
    update_correct_answer_by_name(user, "DAILY") 
  end

  def self.update_correct_answer_by_name(user, name)
    user_counter = user.user_counters.find_by_name(name)
    if user_counter
      if name == "DAILY" && (user_counter.updated_at.strftime("%d") != DateTime.now.utc.strftime("%d"))
        correct_answer_counter_updated = 1
      else
        correct_answer_counter_updated = user_counter.correct_answer + 1
      end
      user_counter.update_attribute(:correct_answer, correct_answer_counter_updated)
    else
      user_counter = UserCounter.create(user_id: user.id, name: name, correct_answer: 1)
    end
  end

  def self.get_by_user(user)
    result = {}
    user.user_counters.map do |counter|
      result[counter.name] = counter
    end
    result
  end
end

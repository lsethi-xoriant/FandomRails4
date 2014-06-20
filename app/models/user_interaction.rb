include ApplicationHelper
include InstantwinHelper
include FandomUtils

class UserInteraction < ActiveRecord::Base
  attr_accessible :user_id, :interaction_id, :answer_id, :promocode_id, :counter

  belongs_to :user
  belongs_to :interaction
  belongs_to :answer
  belongs_to :promocode

  before_save :update_interaction_counter
  after_destroy :update_interaction_counter_down

  # Move in controller.
  # def check_interaction_limit_daily
  #   uicount = Userinteraction.where("user_id=? AND interaction_id=? AND created_at<=? AND created_at>=?", 
  #     user_id, interaction_id, DateTime.now.utc.change(hour: 23).change(min: 59).change(sec: 59), DateTime.now.utc.change(hour: 0).change(min: 0).change(sec: 0)).count
  #   errors.add(:limit_exceeded, "hai raggiunto il limite giornaliero di inviti") if uicount > 4
  # end

  # TODO: this should be reimplemented as a query (1 per answer or, better, just 1 group-by query), and cached
  def update_interaction_counter
    case interaction.resource_type
    when "Like"
      if counter > 0
        interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
      elsif counter < 1
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      end
    when "Quiz"
      if interaction.resource.quiz_type == "VERSUS"
        interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
      elsif interaction.resource.quiz_type == "TRIVIA"
        interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
        if answer && answer.correct
          interaction.resource.update_attribute(:cache_correct_answer, interaction.resource.cache_correct_answer + 1)
        elsif answer && answer.correct.blank?
          interaction.resource.update_attribute(:cache_wrong_answer, interaction.resource.cache_correct_answer + 1)
        end
      end
    else
      interaction.update_attribute(:cache_counter, interaction.cache_counter + 1)
    end
  end

  def update_interaction_counter_down
    case interaction.resource_type
    when "Like"
      if counter > 0
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      end
    when "Play"
      interaction.update_attribute(:cache_counter, interaction.cache_counter - counter)
    when "Quiz"
      if interaction.resource.quiz_type == "VERSUS"
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
      elsif interaction.resource.quiz_type == "TRIVIA"
        interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
        if answer && answer.correct
          interaction.resource.update_attribute(:cache_correct_answer, interaction.resource.cache_correct_answer - 1)
        elsif answer && answer.correct.blank?
          interaction.resource.update_attribute(:cache_wrong_answer, interaction.resource.cache_correct_answer - 1)
        end
      end
    else
      interaction.update_attribute(:cache_counter, interaction.cache_counter - 1)
    end
  end

  def create_or_update_interaction(user_id, interaction_id)
    user_interaction = UserInteraction.find_by_user_id_and_interaction_id(user_id, interaction_id)
    if user_interaction.nil?
      UserInteraction.create(user_id: user_id, interaction_id: interaction_id)
    else
      user_interaction.update_attribute(:counter, user_interaction.counter + 1)
      user_interaction
    end
  end

  private

  # Return true if the current calltoaction is already shared.
  def check_call_to_action_already_shared
    share_inter = self.interaction.calltoaction.interactions.where("resource_type='Share'")
    return !self.user.user_interactions.where("interaction_id in (?)", share_inter.map.collect { |u| u["id"] }).blank?
  end  

  # This might need some caching
  def is_answer_correct?
    answer.correct
  end

end


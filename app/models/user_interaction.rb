include ApplicationHelper
include InstantwinHelper
include FandomUtils

class UserInteraction < ActiveRecord::Base
  attr_accessible :user_id, :interaction_id, :answer_id, :promocode_id, :counter, :like, :outcome

  belongs_to :user
  belongs_to :interaction
  belongs_to :answer
  belongs_to :promocode


  # Move in controller.
  # def check_interaction_limit_daily
  #   uicount = Userinteraction.where("user_id=? AND interaction_id=? AND created_at<=? AND created_at>=?", 
  #     user_id, interaction_id, DateTime.now.utc.change(hour: 23).change(min: 59).change(sec: 59), DateTime.now.utc.change(hour: 0).change(min: 0).change(sec: 0)).count
  #   errors.add(:limit_exceeded, "hai raggiunto il limite giornaliero di inviti") if uicount > 4
  # end

  def self.create_or_update_interaction(user_id, interaction_id, answer_id, like)
    user_interaction = find_by_user_id_and_interaction_id(user_id, interaction_id)
    if user_interaction.nil?
      create(user_id: user_id, interaction_id: interaction_id, answer_id: answer_id, like: like)
    else
      user_interaction.update_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, like: like)
      user_interaction
    end
  end

  # This might need some caching
  def is_answer_correct?
    answer.nil? || answer.correct
  end

  private

  def check_call_to_action_already_shared
    share_inter = self.interaction.calltoaction.interactions.where("resource_type='Share'")
    return !self.user.user_interactions.where("interaction_id in (?)", share_inter.map.collect { |u| u["id"] }).blank?
  end  

end


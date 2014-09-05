include ApplicationHelper
include InstantwinHelper
include FandomUtils

class UserInteraction < ActiveRecord::Base
  attr_accessible :user_id, :interaction_id, :answer_id, :promocode_id, :counter, :like, :outcome, :aux

  belongs_to :user
  belongs_to :interaction
  belongs_to :answer
  belongs_to :promocode

  def self.merge_aux(aux_1, aux_2)
    return aux_1 if aux_2.nil?
    return aux_2 if aux_1.nil?

    aux_1 = JSON.parse(aux_1)
    aux_2 = JSON.parse(aux_2)

    aux_2.each do |key, value|
      if aux_1[key].present?
        aux_1[key] = aux_1[key] + value
      else
        aux_1[key] = value
      end
    end

    aux_1

  end

  def self.create_or_update_interaction(user_id, interaction_id, answer_id, like, aux = nil)
    user = User.find(user_id)
    user_interaction = find_by_user_id_and_interaction_id(user_id, interaction_id)
    if user_interaction.nil?
      user_interaction = create(user_id: user_id, interaction_id: interaction_id, answer_id: answer_id, like: like, aux: aux)
      UserCounter.update_unique_counters(user_interaction, user)
    else
      user_interaction.update_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, like: like, aux: UserInteraction.merge_aux(user_interaction.aux, aux).to_json)
    end
    UserCounter.update_all_counters(user_interaction, user)
    user_interaction
  end

  # This might need some caching
  def is_answer_correct?
    answer.nil? || answer.correct
  end

end


require 'fandom_utils'

module CallToActionHelper
  
  def call_to_action_completed?(cta, user)
    all_interactions = cta.interactions.where("required_to_complete")
    interactions_done = all_interactions.includes(:user_interactions).where("user_id = ?", user.id)
    all_interactions.count == interaction_done.count
  end
  
end
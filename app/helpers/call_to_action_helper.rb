require 'fandom_utils'

module CallToActionHelper
  
  def call_to_action_completed?(cta, user)
    all_interactions = cta.interactions.where("required_to_complete")
    interactions_done = all_interactions.includes(:user_interactions).where("user_interactions.user_id = ?", user.id)
    all_interactions.any? && (all_interactions.count == interactions_done.count)
  end
  
  def get_cta_template_option_list
    CallToAction.includes({:call_to_action_tags => :tag}).where("tags.name ILIKE 'template'").map{|cta| [cta.id, cta.title]}
  end
  
end

call_to_action = CallToAction.where(
  :title => "Cta with share interaction", 
  :name => "cta-with-share-interaction", 
  :slug => "cta-with-share-interaction"
).first_or_create
call_to_action.update_attribute(:activation_date_time, Time.now)

share = Share.where(
  :providers => {
    "facebook" => {
      "message" => "", 
      "description" => "", 
      "link" => ""
    }, 
    "twitter" => {
      "message" => "", 
      "link" => ""
    }, 
    "gplus" => {
      "message" => "", 
      "description" => "", 
      "link" => ""
    }, 
    "whatsapp" => {
      "message" => "", 
      "link" => ""
    }, 
    "linkedin" => {
      "message" => "", 
      "description" => "", 
      "link" => ""
    }, 
    "email" => {}, 
    "direct_url" => {}
  }
).first_or_create

interaction = Interaction.where(
  when_show_interaction: "SEMPRE_VISIBILE", 
  required_to_complete: false, 
  resource_id: share.id, 
  resource_type: "Share", 
  call_to_action_id: call_to_action.id, 
  stored_for_anonymous: false, 
  aux: {}, 
  interaction_positioning: "UNDER_MEDIA"
).first_or_create

call_to_action
gallery_cta = CallToAction.where(:title => "Instagram gallery", :name => "instagram-gallery").first_or_create
template_cta = CallToAction.where(:title => "Template Instagram gallery", :name => "template-instagram-gallery").first_or_create
upload = Upload.where(:call_to_action_id => template_cta.id, :title_needed => true).first_or_create
interaction = Interaction.where(:call_to_action_id => gallery_cta.id, :resource_type => "Upload", :resource_id => upload.id).first_or_create
interaction.update_attribute(:aux, { 
  "configuration" => { 
    "type" => "instagram",
    "instagram_tag" => {
      "name" => "fandom_shado",
      "subscription_id" => 18261539,
      "registered_users_only" => false
    }
  }
})

instagram_subscriptions_setting = Setting.where(:key => INSTAGRAM_SUBSCRIPTIONS_SETTINGS_KEY).first_or_create
instagram_subscriptions_setting.value = { 
  "fandom_shado" => { 
    "subscription_id" => 18261539,
    "interaction_id" => interaction.id,
    "min_tag_id" => nil
  }
}.to_json
instagram_subscriptions_setting.save

interaction
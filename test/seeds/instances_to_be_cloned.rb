call_to_action_params = { 
  name: "cta-to-be-cloned", 
  title: "Cta to be cloned", 
  description: "This is a testing call to action", 
  media_type: "IMAGE", 
  enable_disqus: false, 
  activated_at: DateTime.parse("2015-03-16"), 
  slug: "cta-to-be-cloned", 
  media_data: "test-image.jpg", 
  valid_from: DateTime.parse("2015-03-16"), 
  valid_to: DateTime.parse("2016-03-16")
}

call_to_action = CallToAction.where(call_to_action_params).first

call_to_action_created_now = call_to_action.nil?
if call_to_action_created_now
  call_to_action = CallToAction.create(call_to_action_params)
end

call_to_action.aux = { "aux_field_test" => "value" }
call_to_action.extra_fields = { "extra_field_test" => "value" }
call_to_action.save

if call_to_action_created_now

  # Resources creation
  resources = {
    "share" => Share.create(providers: { "test_provider_1" => {}, "test_provider_2" => {} }),
    "check" => Check.create(title: "Check for testing", description: "Just a testing check"),
    "quiz" => Quiz.create(question: "What are you testing for?", quiz_type: "VERSUS", one_shot: true),
    "play" => Play.create(title: "Play for testing"),
    "vote" => Vote.create(title: "Vote for testing", vote_min: 1, vote_max: 10, one_shot: true, extra_fields: { "extra_field_test" => "value" }),
    "comment" => Comment.create(must_be_approved: true, title: "Comment for testing"),
    "like" => Like.create(title: "Like for testing"),
    "download" => Download.create(title: "Donwload for testing", ical_fields: {}),
    "link" => Link.create(url: "http://www.testingissoboring.com", title: "Link for testing"),
    "upload" => Upload.create(call_to_action_id: 1234, releasing: true, releasing_description: "Release me, release my body", privacy: true, privacy_description: "I need my privacy", upload_number: 1234, title_needed: false)
  }

  # Interactions creation
  resources.each do |resource_type, resource_instance|
    interaction = Interaction.where(
      name: "interaction-#{resource_type}-test", 
      when_show_interaction: "SEMPRE_VISIBILE", 
      required_to_complete: true, 
      resource_id: resource_instance.id, 
      resource_type: resource_type.capitalize, 
      call_to_action_id: call_to_action.id, 
      aux: {}, 
      stored_for_anonymous: false, 
      registration_needed: false
    ).first_or_create
  end

end

# tag = Tag.where(name: "tag-to-be-cloned", description: "Just a testing tag", locked: false, extra_fields: {}, title: "Tag to be cloned", slug: "tag-to-be-cloned").first_or_create

reward = Reward.where(title: "Reward to be cloned", short_description: "Testing reward", long_description: "To be cloned", cost: 50, media_type: "DIGITALE", currency_id: 1234, spendable: false, countable: false, numeric_display: false, name: "reward-to-be-cloned", call_to_action_id: 1234).first_or_create

[call_to_action, resources, reward]

# Simple cherry-like linked call to action structure
starting_cta = CallToAction.where(:title => "Starting call to action", :name => "starting-call-to-action-for-testing").first_or_create
cta_1 = CallToAction.where(:title => "1", :name => "linked-cta-helper-test-cta-1").first_or_create
cta_2 = CallToAction.where(:title => "2", :name => "linked-cta-helper-test-cta-2").first_or_create

starting_cta_interaction = Interaction.where(:call_to_action_id => starting_cta.id).first_or_create
cta_1_interaction = Interaction.where(:call_to_action_id => cta_1.id).first_or_create
cta_2_interaction = Interaction.where(:call_to_action_id => cta_2.id).first_or_create

[cta_1, cta_2].each do |cta|
  interaction_id = starting_cta.interactions.all.first.id
  InteractionCallToAction.where(:interaction_id => interaction_id, :call_to_action_id => cta.id).first_or_create
end

[starting_cta, cta_1, cta_2]
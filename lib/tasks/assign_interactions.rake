namespace :assign_interactions do

  task :assign_share => :environment do
    switch_tenant("disney")

    aux = {
      email: {}
    }.to_json

    CallToAction.all.each do |calltoaction|
      if calltoaction.interactions.where("resource_type = 'Share'").count < 1 
        resource = Share.create(providers: aux)
        interaction = Interaction.create(name: "INTRSHARE#{calltoaction.id}", when_show_interaction: "SEMPRE_VISIBILE", required_to_complete: false, resource: resource, call_to_action_id: calltoaction.id)
        puts calltoaction.title
      end
    end 
  end

  task :assign_vote => :environment do
    switch_tenant("disney")

    CallToAction.where("user_id IS NOT NULL").each do |calltoaction|
      if calltoaction.interactions.where("resource_type = 'Vote'").count < 1 
        resource = Vote.create(vote_min: 1, vote_max: 5)
        interaction = Interaction.create(name: "INTRVOTE#{calltoaction.id}", when_show_interaction: "SEMPRE_VISIBILE", required_to_complete: false, resource: resource, call_to_action_id: calltoaction.id)
        puts calltoaction.title
      end
    end 
  end

end

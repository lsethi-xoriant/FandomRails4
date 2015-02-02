namespace :assign_share_interactions do


  desc "Genera tutte le data e ora di vincita del concorso"
  task :assign => :environment do
    switch_tenant("disney")

    aux = {
      email: {}
    }.to_json

    CallToAction.all.each do |calltoaction|
      if calltoaction.interactions.where("resource_type = 'share'").count < 1 
        resource = Share.create(providers: aux)
        interaction = Interaction.create(name: "INTRSHARE#{calltoaction.id}", when_show_interaction: "SEMPRE_VISIBILE", required_to_complete: false, resource: resource, call_to_action_id: calltoaction.id)
        puts calltoaction.title
      end
    end 
  end

end

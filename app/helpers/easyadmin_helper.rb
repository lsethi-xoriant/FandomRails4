module EasyadminHelper

  def get_all_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.includes(call_to_action_tags: :tag).where("tags.name = ?", tag_name).order("activated_at DESC").to_a
    end
  end

  def get_property_from_cta(cta)
    properties_tag = get_tag_with_tag_about_call_to_action(cta, "property")
    if properties_tag.empty?
      ""
    else
      "#{properties_tag.first.name}"
    end
  end

  def aws_trasconding_not_required_or_completed(cta)
    aux = JSON.parse(cta.aux || "{}")
    @aws_transcoding_media_status = aux["aws_transcoding_media_status"]
    !@aws_transcoding_media_status || @aws_transcoding_media_status == "done"
  end

  def link_to_add_check_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Check.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/check-form", f: builder)
    end
    link_to_function(name, "add_check_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

  # TODO: start here to uniform methods
  def link_to_add_comment_fields(name, f, association, resource)
    link_to_add_fields(name, f, association, resource)
  end

  def link_to_add_fields(name, f, association, resource, template = resource)
    new_object = Interaction.new

    attr = {}
    if resource.singularize.classify.constantize.new.attributes.keys.include?(:title)
      attr = {
        title: "##{resource.upcase}#{ DateTime.now.strftime("%Y%m%d") }"
      }
    end

    new_object.resource = resource.singularize.classify.constantize.new(attr)
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/#{template}-form", f: builder)
    end

    link_to_function(name, "add_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\", \"#{template}\")", class: "btn btn-primary btn-block")
  end

  def link_to_add_download_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Download.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/download-form", f: builder)
    end
    link_to_function(name, "add_download_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

  def link_to_add_play_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Play.new(title: "#PLAY#{ DateTime.now.strftime("%Y%m%d") }")
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/play-form", f: builder)
    end
    link_to_function(name, "add_play_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs btn-block")
  end

  def link_to_add_share_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Share.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/share-form", f: builder)
    end
    link_to_function(name, "add_share_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

  def link_to_add_like_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Like.new(title: "#LIKE#{ DateTime.now.strftime("%Y%m%d") }")
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/like-form", f: builder)
    end
    link_to_function(name, "add_like_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

  def link_to_add_quiz_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Quiz.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/quiz-form", f: builder)
    end
    link_to_function(name, "add_quiz_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

  def link_to_add_versus_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Quiz.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/versus-form", f: builder)
    end
    link_to_function(name, "add_versus_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

  def link_to_add_answer_quiz_fields(name, f, association)
    new_object = Answer.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/answer-quiz-form", f: builder)
    end
    link_to_function(name, "add_answer_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-secondary btn-xs")
  end

  def link_to_add_answer_versus_fields(name, f, association)
    new_object = Answer.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/answer-versus-form", f: builder)
    end
    link_to_function(name, "add_answer_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-secondary btn-xs")
  end

  def link_to_add_answer_test_fields(name, f, association)
    new_object = Answer.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/answer-test-form", f: builder)
    end
    link_to_function(name, "add_answer_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-secondary btn-xs")
  end

  def link_to_add_contest_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/contest-form", f: builder)
    end
    link_to_function(name, "add_contest_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end
  
  def link_to_add_upload_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Upload.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/upload-form", f: builder)
    end
    link_to_function(name, "add_upload_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end
  
  def link_to_add_vote_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Vote.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/vote-form", f: builder)
    end
    link_to_function(name, "add_vote_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_remove_fields(name, resource, template = resource)
    link_to_function(name, "remove_fields(this, \"#{template}\")", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_check_fields(name)
    link_to_function(name, "remove_check_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_download_fields(name)
    link_to_function(name, "remove_download_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_quiz_fields(name)
    link_to_function(name, "remove_quiz_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_versus_fields(name)
    link_to_function(name, "remove_versus_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_answer_quiz_fields(name)
    link_to_function(name, "remove_answer_quiz_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_answer_versus_fields(name)
    link_to_function(name, "remove_answer_versus_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_like_fields(name)
    link_to_function(name, "remove_like_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_play_fields(name)
    link_to_function(name, "remove_play_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_comment_fields(name)
    link_to_function(name, "remove_comment_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_share_fb_fields(name)
    link_to_function(name, "remove_share_fb_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_share_tt_fields(name)
    link_to_function(name, "remove_share_tt_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_share_email_fields(name)
    link_to_function(name, "remove_share_email_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_contest_fields(name)
    link_to_function(name, "remove_contest_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_upload_fields(name)
    link_to_function(name, "remove_upload_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_vote_fields(name)
    link_to_function(name, "remove_vote_fields(this)", class: "btn btn-warning btn-xs")
  end

  def create_and_link_attachment(param, model_instance)
    if param[:extra_fields].present?
      param[:extra_fields].each do |extra_field_name, extra_field_value|
        if extra_field_value.is_a?(String)
          param[:extra_fields][extra_field_name] = extra_field_value
        elsif extra_field_value[:type] == "string"
          param[:extra_fields][extra_field_name] = extra_field_value[:value]
        elsif extra_field_value[:type] == "html"
          param[:extra_fields][extra_field_name] = { "type" => "html", "value" => extra_field_value[:value] }
        elsif extra_field_value[:type] == "date"
          param[:extra_fields][extra_field_name] = { "type" => "date", "value" => extra_field_value[:value] }
        elsif (extra_field_value[:type] == "bool" || extra_field_value[:type] =="boolean")
          param[:extra_fields][extra_field_name] = { "type" => "bool", "value" => extra_field_value[:value] == "true" }
        else # it's not a string
          if extra_field_value[:value].present?
            attachment = Attachment.create(data: extra_field_value[:value])
            extra_field_value[:attachment_id] = attachment.id
            extra_field_value[:url] = attachment.data.url
            extra_field_value.delete :value
          else
            if model_instance.present?
              value_of_extra_field = JSON.parse(model_instance.extra_fields)[extra_field_name]
              extra_field_value[:type] = "media"
              if value_of_extra_field.nil?
                extra_field_value[:attachment_id] = "null"
                extra_field_value[:url] = "null"
              else
                extra_field_value[:attachment_id] = value_of_extra_field["attachment_id"]
                extra_field_value[:url] = value_of_extra_field["url"]
              end
            end
          end
        end
      end
    else
      param[:extra_fields] = "{}"
    end
  end

  def get_period_ids(from_date, to_date)
    Period.where("start_datetime >= '#{from_date.strftime('%Y-%m-%d 00:00:00')}' 
                    AND end_datetime <= '#{to_date.strftime('%Y-%m-%d 23:59:59')}'
                    AND kind = 'daily'").pluck(:id)
  end

  def find_user_reward_count_by_reward_name_at_date(reward_name, period_ids)
    reward_id = Reward.find_by_name(reward_name).id rescue 0
    period_ids.empty? ? 0 : UserReward.where("reward_id = #{reward_id} AND period_id IN (#{period_ids.join(', ')})").pluck("sum(counter)").first.to_i
  end

  def is_linking?(cta_id)
    CallToAction.find(cta_id).interactions.each do |interaction|
      return true if (InteractionCallToAction.find_by_interaction_id(interaction.id) or call_to_action_answers_linked_cta(cta_id).any? )
    end
    false
  end

  def is_linked?(cta_id)
    return true if (InteractionCallToAction.find_by_call_to_action_id(cta_id) or Answer.find_by_call_to_action_id(cta_id) )
    false
  end

  def call_to_action_answers_linked_cta(cta_id)
    res = []
    Interaction.where(:resource_type => "Quiz", :call_to_action_id => cta_id).each do |interaction|
      Answer.where(:quiz_id => interaction.resource_id).each do |answer|
        res << { answer.id => answer.call_to_action_id } if answer.call_to_action_id
      end
    end
    res
  end

  def save_interaction_call_to_action_linking(cta)
    ActiveRecord::Base.transaction do
      cta.interactions.each do |interaction|
        interaction.save!
        InteractionCallToAction.where(:interaction_id => interaction.id).destroy_all
        # if called on a new cta, linked_cta is a hash containing a list of { "condition" => <condition>, "cta_id" => <next cta id> } hashes
        links = interaction.resource.linked_cta rescue nil
        unless links
          params["call_to_action"]["interactions_attributes"].each do |key, value|
            links = value["resource_attributes"]["linked_cta"] if value["id"] == interaction.id.to_s
          end
        end
        if links
          links.each do |key, link|
            if CallToAction.exists?(link["cta_id"].to_i)
              condition = link["condition"].blank? ? nil : { link["condition"] => link["parameters"] }.to_json
              InteractionCallToAction.create(:interaction_id => interaction.id, :call_to_action_id => link["cta_id"], :condition => condition )
            else
              cta.errors.add(:base, "Non esiste una call to action con id #{link["cta_id"]}")
            end
          end
        end
      end
      build_jstree_and_check_for_cycles(cta)
      if cta.errors.any?
        raise ActiveRecord::Rollback
      end
    end
    return cta.errors.empty?
  end

  def build_jstree_and_check_for_cycles(current_cta)
    current_cta_id = current_cta.id
    trees, cycles = CtaForest.build_trees(current_cta_id)
    data = []
    trees.each do |root|
      data << build_node_entries(root, current_cta_id) 
    end
    res = { "core" => { "data" => data } }
    if cycles.any?
      message = "Sono presenti cicli: \n"
      cycles.each do |cycle|
        cycle.each_with_index do |cta_id, i|
          message += (i + 1) != cycle.size ? "#{CallToAction.find(cta_id).name} --> " 
            : "#{CallToAction.find(cta_id).name} --> #{CallToAction.find(cycle[0]).name}\n"
        end
      end
      current_cta.errors[:base] << message
    end
    res.to_json
  end

  def build_node_entries(node, current_cta_id)
    if node.value == current_cta_id
      icon = "fa fa-circle"
    else
      cta_tags = get_cta_tags_from_cache(CallToAction.find(node.value))
      if cta_tags.include?('step')
        icon = "fa fa-step-forward"
      elsif cta_tags.include?('ending')
        icon = "fa fa-flag-checkered"
      else
        icon = "fa fa-long-arrow-right"
      end
    end
    res = { "text" => "#{CallToAction.find(node.value).name}", "icon" => icon }
    if node.children.any?
      res.merge!({ "state" => { "opened" => true }, 
                "children" => (node.children.map do |child| build_node_entries(child, current_cta_id) end) })
    end
    res
  end

end


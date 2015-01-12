module EasyadminHelper

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
    new_object = Interaction.new
    new_object.resource = resource.singularize.classify.constantize.new(title: "##{resource.upcase}#{ DateTime.now.strftime("%Y%m%d") }")
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/#{resource}-form", f: builder)
    end
    link_to_function(name, "add_#{resource}_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
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

  def link_to_add_contest_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/contest-form", f: builder)
    end
    link_to_function(name, "add_contest_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end
  
  def link_to_add_tag_fields(name, f, association)
    new_object = TagField.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/tag/tag-field-form", f: builder)
    end
    link_to_function(name, "add_tag_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
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

  def link_to_remove_tag_fields(name, tag_field_id)
    link_to_function(name, "remove_tag_fields(this, #{tag_field_id.present?})", class: "btn btn-warning btn-xs")
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
        elsif extra_field_value[:type] == 'string'
          param[:extra_fields][extra_field_name] = extra_field_value[:value]
        else # it's not a string
          if extra_field_value[:value].present?
            attachment = Attachment.create(data: extra_field_value[:value])
            extra_field_value[:attachment_id] = attachment.id
            extra_field_value[:url] = attachment.data.url
            extra_field_value.delete :value
          else
            if model_instance.present?
              value_of_extra_field = JSON.parse(model_instance.extra_fields)[extra_field_name]
              extra_field_value[:type] = 'media'
              if value_of_extra_field.nil?
                extra_field_value[:attachment_id] = 'null'
                extra_field_value[:url] = 'null'
              else
                extra_field_value[:attachment_id] = value_of_extra_field['attachment_id']
                extra_field_value[:url] = value_of_extra_field['url']
              end
            end
          end
        end
      end
    else
      param[:extra_fields] = "{}"
    end
  end

end


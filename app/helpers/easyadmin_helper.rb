# encoding: utf-8
module EasyadminHelper

  def link_to_add_check_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Check.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/check-form", f: builder)
    end
    link_to_function(name, "add_check_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-block")
  end

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

  def instagram_upload?(interaction_id)
    !JSON.parse(Interaction.find(interaction_id).aux)["instagram_tag"].nil? rescue false
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

  def render_update_banner(updated_at, instance)

    if instance.class == CallToAction
      tag_ids = CallToActionTag.where(:call_to_action_id => instance.id).pluck(:tag_id)
    elsif instance.class == Reward
      tag_ids = RewardTag.where(:reward_id => instance.id).pluck(:tag_id)
    elsif instance.class == Tag
      tag_ids = TagsTag.where(:tag_id => instance.id).pluck(:other_tag_id)
    else
      tag_ids = []
    end

    banner = <<EOF 
      <div class="row">
        <div class="col-lg-12">
          <div id="update-banner-message" class="alert alert-warning">
            <p class="col-lg-10"> Alcuni contenuti sono stati modificati, per completare l'aggiornamento del sistema 
             è necessario aggiornare la cache premendo il seguente pulsante </p>
            <button type="button" class="btn btn-primary btn-xs" onclick="updateTagsUpdatedAt(
EOF
    banner += "'#{ updated_at }', '#{ tag_ids.join(",") }'"

    banner += <<EOF
            )">Aggiorna cache</button>
          </div>
        </div>
      </div>


      <script type="text/javascript">
        function updateTagsUpdatedAt(updatedAt, tagIds) {
          url = "/easyadmin/tag/update_updated_at/" + updatedAt
          if(tagIds != "")
            url += "/" + tagIds
          $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
              document.getElementById("update-banner-message").innerHTML = "Contenuti aggiornati con successo";
            }
          });
        }
      </script>
EOF
    banner.html_safe
  end

end
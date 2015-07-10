# encoding: utf-8
module EasyadminHelper

  def adjust_when_show_interactions_for_form()
    when_types = []
    WHEN_SHOW_USER_INTERACTION.each do |when_type|
      when_types << [when_type, when_type]
    end
    when_types
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
      render("/easyadmin/call_to_action/#{template}_form", f: builder)
    end

    link_to name, "#", :onclick => h("add_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\", \"#{template}\")"), class: "btn btn-primary btn-block", remote: true
  end

  def link_to_add_answer_fields(name, f, association, resource, template = resource)
    new_object = Answer.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/call_to_action/answer_#{template}_form", f: builder)
    end
    link_to name, "#", :onclick => h("add_answer_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"), class: "btn btn-secondary btn-xs", remote: true 
  end

  def link_to_add_contest_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/contest_form", f: builder)
    end
    link_to name, "#", :onclick => h("add_contest_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"), class: "btn btn-primary btn-block", remote: true 
  end

  def link_to_remove_fields(name, resource, template = resource)
    link_to name, "#", :onclick => h("remove_fields(this, \"#{ template }\")"), class: "btn btn-warning btn-xs", remote: true
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
              value_of_extra_field = model_instance.extra_fields[extra_field_name]
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

  def array_or_string_for_javascript(option)
    if option.kind_of?(Array)
      "['#{option.join('\',\'')}']"
    elsif !option.nil?
      "'#{option}'"
    end
  end

  def get_upload_type(interaction_id)
    Interaction.find(interaction_id).aux["configuration"]["type"] rescue nil
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

  def get_step_and_ending_test_cta()
    cta_list = []
    unactive_cta_list = []

    CallToAction.includes(call_to_action_tags: :tag)
    .select('call_to_actions.id, call_to_actions.name')
    .where("tags.name='step' OR tags.name = 'ending'")
    .references(:call_to_action_tags)
    .order("activated_at DESC").each do |cta| 
      if (cta.activated_at.nil? || cta.activated_at > Time.now.utc)
        unactive_cta_list << {"id" => cta.id, "text" => cta.name}
      else
        cta_list << {"id" => cta.id, "text" => cta.name}
      end
    end
    [cta_list, unactive_cta_list]
  end

  def get_random_interaction_tag(randomform)
    if params["action"] == "clone"
      CallToAction.find(params["id"]).interactions.each do |interaction|
        return RandomResource.find(interaction.resource.id).tag if interaction.resource_type == "RandomResource"
      end
    end
    return RandomResource.find(randomform.object.id).tag rescue nil
  end

  def export_user_call_to_actions(call_to_action_ids)
    aux_columns = get_cta_columns_from_json_fields(call_to_action_ids, "aux")

    transcoding_settings = get_deploy_setting("sites/#{$site.id}/transcoding", false)
    if transcoding_settings
      original_media_path = "#{transcoding_settings[:s3_output_folder]}/original/"
    end

    csv = "Cta ID;Slug;Media;Liberatoria"
    csv += ";" + aux_columns.map{ |col| col.capitalize.gsub("_", " ") }.join(";") if aux_columns.any?
    csv += "\n"

    CallToAction.where(:id => call_to_action_ids).each do |cta|
      csv << "#{cta.id};#{cta.slug};#{ original_media_path ? "#{original_media_path}#{cta.user_id}-#{cta.id}-media.mp4" : cta.media_image.url };#{ cta.releasing_file.file.url if cta.releasing_file.present? }"
      cta_aux = cta.aux
      if cta_aux
        aux_columns.each do |aux_column|
          csv << ";#{cta_aux[aux_column]}"
        end
      end
      csv << "\n"
    end

    send_data(csv, :tye => 'text/csv; charset=utf-8; header=present', :filename => "user_call_to_actions_#{Time.now.strftime("%Y_%m_%d_%H_%M")}.csv")
  end

  def get_cta_columns_from_json_fields(cta_ids, json_field)
    columns = Set.new
    cta_ids.each do |cta_id|
      json_field_hash = CallToAction.find(cta_id)[json_field]
      if json_field_hash
        json_field_hash.keys.each do |key|
          columns = columns.add(key)
        end
      end
    end
    columns
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
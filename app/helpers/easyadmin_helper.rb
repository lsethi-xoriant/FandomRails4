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

  def set_filter_values(params, value = nil)
    filters = {}
    params_filters = params[:filters]
    if params_filters
      if params_filters.is_a? String
        params_filters = eval(params_filters)
      end
      params_filters.each do |k, v|
        if !value.nil?
          filters[k] = value
        else
          filters[k] = v
        end
      end
    end
    filters
  end

  def get_user_list(filters)
    where_conditions = ["anonymous_id IS NULL"]
    where_conditions << "email ILIKE '%#{filters["email"]}%'" unless filters["email"].blank?
    where_conditions << "username ILIKE '%#{filters["username"]}%'" unless filters["username"].blank?
    unless filters["from_date"].blank?
      created_at_from = time_parsed_to_utc("#{filters["from_date"]} 00:00:00")
      where_conditions << "created_at >= '#{created_at_from}'"
    end
    unless filters["to_date"].blank?
      created_at_to = time_parsed_to_utc("#{filters["to_date"]} 23:59:59")
      where_conditions << "created_at <= '#{created_at_to}'"
    end

    where_conditions_string = where_conditions.join(" AND ")
    User.where(where_conditions_string)
  end

  def get_users_export_url(filters)
    url = "/easyadmin/export_users/"
    filters.reject{|k, v| v.blank?}.each_with_index do |(name, value), i|
      connector = i == 0 ? "?" : "&"
      url += "#{connector}#{name}=#{value}" unless value.blank?
    end
    url
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

  def set_cta_updated_at(cta)
    if cta.interactions.any?
      resources_updated_at = []
      cta.interactions.each do |interaction|
        resources_updated_at << interaction.resource.updated_at
      end
      max_resources_updated_at = resources_updated_at.max
      cta.update_attribute(:updated_at, max_resources_updated_at) if cta.updated_at < max_resources_updated_at
    end
  end

  def get_content_updated_at_cookie()
    cookies[:content_updated_at]
  end

  def set_content_updated_at_cookie(updated_at = nil)
    if cookies[:content_updated_at].nil?
      updated_at_datetime = updated_at || DateTime.now
      cookies[:content_updated_at] = updated_at_datetime.utc.strftime("%Y-%m-%d %H:%M:%S.%L")
    end
  end

  def get_user_call_to_action_moderation_cookie()
    cookies[:user_call_to_action_moderation]
  end

  def set_user_call_to_action_moderation_cookie()
    cookies[:user_call_to_action_moderation] = true
  end

  def delete_updating_content_cookies()
    cookies.delete(:content_updated_at)
    cookies.delete(:user_call_to_action_moderation)
  end

  def get_cta_action_buttons(call_to_action, show_page = false)
    actions = [
      {
        "url" => is_call_to_action_gallery(call_to_action) ? "/gallery/#{call_to_action.id}" : "/call_to_action/#{call_to_action.id}", 
        "icon" => "fa fa-external-link", 
        "title" => "Vai alla CTA"
      }, 
      {
        "url" => "/easyadmin/cta/show/#{call_to_action.id}", 
        "icon" => "fa fa-info-circle", 
        "title" => "Info"
      }, 
      {
        "url" => "/easyadmin/cta/edit/#{call_to_action.id}", 
        "icon" => "fa fa-pencil-square-o", 
        "title" => "Edita"
      }, 
      {
        "url" => "/easyadmin/cta/tag/#{call_to_action.id}", 
        "icon" => "fa fa-tag", 
        "title" => "Tagga"
      }, 
      {
        "url" => "/easyadmin/cta/clone/#{call_to_action.id}", 
        "icon" => "fa fa-copy", 
        "title" => "Clona"
      }, 
      {
        "url" => "javascript: void(0)", 
        "icon" => "fa fa-eye", 
        "title" => call_to_action.activated_at.blank? ? "Attiva" : "Disattiva",  
        "style" => call_to_action.activated_at.blank? ? "color: gray" : "color: red", 
        "id" => "eye-#{call_to_action.id}", 
        "onclick" => "hideCalltoaction('#{call_to_action.id}')"
      }, 
    ]

    if show_page

      buttons = <<-EOF
        <script type="text/javascript">
          function hideCalltoaction(id){
            $.ajax({
              type: "POST",
              url: "/easyadmin/cta/hide/" + id,
              beforeSend: function(jqXHR, settings) {
                  jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
              },
              success: function(data) {
                if(data == "active") {
                  $("#eye-" + id).attr("title", "Disattiva");
                  html = $("#eye-" + id).parent().html();
                  html = html.replace("Attiva", "Disattiva");
                  $("#eye-" + id).parent().html(html);
                }
                else {
                  $("#eye-" + id).attr("title", "Attiva");
                  html = $("#eye-" + id).parent().html();
                  html = html.replace("Disattiva", "Attiva");
                  $("#eye-" + id).parent().html(html);
                }
              }
            });
          }
        </script>
      EOF

      actions.each_with_index do |action, i|
        unless (action["title"] == "Edita" && !can?(:manage, :all)) || action["title"] == "Info"
          buttons += get_action_button_for_show_page(action)
        end
      end

    else

      buttons = <<-EOF
        <script type="text/javascript">
          function hideCalltoaction(id){
            $.ajax({
              type: "POST",
              url: "/easyadmin/cta/hide/" + id,
              beforeSend: function(jqXHR, settings) {
                  jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
              },
              success: function(data) {
                if(data == "active") 
                  $("#eye-" + id).css("color", "red");
                else
                  $("#eye-" + id).css("color", "gray");
              }
            });
          }
        </script>
      EOF

      actions.each do |action|
        buttons += <<-EOF
        <div class="col-sm-1" style="margin: 0;">
          <a href="#{action["url"]}"#{action["onclick"] ? " onclick=\"#{action["onclick"]}\"" : ""}><i #{action["id"] ? "id='#{action["id"]}'" : ""} class="#{action["icon"]}" style="#{action["style"] || "color: red"}" title="#{action["title"]}"></i></a>
        </div>
        EOF
      end

    end

    buttons.html_safe
  end

  def get_tag_buttons(tag, show_page = false)
    actions = [
      {
        "url" => "/easyadmin/tag/#{tag.id}", 
        "icon" => "fa fa-info-circle", 
        "title" => "Info"
      }, 
      {
        "url" => "/easyadmin/tag/#{tag.id}/edit", 
        "icon" => "fa fa-pencil-square-o", 
        "title" => "Edita"
      }, 
      {
        "url" => "/easyadmin/tag/clone/#{tag.id}", 
        "icon" => "fa fa-copy", 
        "title" => "Clona"
      }
    ]

    buttons = ""

    if show_page

      actions.each do |action|
        unless action["title"] == "Info"
          buttons += get_action_button_for_show_page(action)
        end
      end

    else

      actions.each do |action|
        buttons += <<-EOF
          <div class="col-sm-1" style="margin: 0;">
            <a href="#{action["url"]}"><i class="#{action["icon"]}" style="#{action["style"] || "color: red"}" title="#{action["title"]}"></i></a>
          </div>
        EOF
      end

    end

    buttons.html_safe
  end

  def get_reward_buttons(reward, show_page = false)
    actions = [
      {
        "url" => "/easyadmin/reward/show/#{reward.id}", 
        "icon" => "fa fa-info-circle", 
        "title" => "Info"
      }, 
      {
        "url" => "/easyadmin/reward/edit/#{reward.id}", 
        "icon" => "fa fa-pencil-square-o", 
        "title" => "Edita"
      }, 
      {
        "url" => "/easyadmin/reward/clone/#{reward.id}", 
        "icon" => "fa fa-copy", 
        "title" => "Clona"
      }
    ]

    buttons = ""

    if show_page

      actions.each do |action|
        unless action["title"] == "Info"
          buttons += get_action_button_for_show_page(action)
        end
      end

    else

      actions.each do |action|
        buttons += <<-EOF
          <div class="col-sm-1" style="margin: 0;">
            <a href="#{action["url"]}"><i class="#{action["icon"]}" style="#{action["style"] || "color: red"}" title="#{action["title"]}"></i></a>
          </div>
        EOF
      end

    end

    buttons.html_safe
  end

  def get_user_buttons(user, show_page = false)
    actions = [
      {
        "url" => "/easyadmin/user/show/#{user.id}", 
        "icon" => "fa fa-info-circle", 
        "title" => "Info"
      }, 
      {
        "url" => "/rails_admin/user/#{user.id}/edit", 
        "icon" => "fa fa-adn", 
        "title" => "Rails Admin"
      }, 
      {
        "url" => "/user/sign_in_as/#{user.id}", 
        "icon" => "fa fa-sign-in", 
        "title" => "Loggati come"
      }
    ]

    buttons = ""

    if show_page

      actions.each do |action|
        unless action["title"] == "Info"
          buttons += get_action_button_for_show_page(action)
        end
      end

    else

      actions.each do |action|
        buttons += <<-EOF
          <div class="col-sm-1" style="margin: 0;">
            <a href="#{action["url"]}"><i class="#{action["icon"]}" style="#{action["style"] || "color: red"}" title="#{action["title"]}"></i></a>
          </div>
        EOF
      end

    end

    buttons.html_safe
  end

  def get_action_button_for_show_page(action)
    res = <<-EOF
      <a href="#{action["url"]}"#{action["onclick"] ? " onclick=\"#{action["onclick"]}\"" : ""}>
        <button type="button" class="btn btn-primary">
        <i #{action["id"] ? "id='#{action["id"]}'" : ""} class="#{action["icon"]}" title="#{action["title"]}"></i>
          #{action["title"]}
        </button>
      </a>
    EOF
    res
  end

end
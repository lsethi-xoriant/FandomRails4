module TagBoxHelper

  def render_html_tag_box(id_text_field, instance_text_field, new_tag_message)
    
    tag_list = raw(Tag.select("name").where("valid_to IS NULL OR valid_to > now()").map(&:name).to_json)
    unactive_tags_name = raw(Tag.where("valid_to < now()").pluck("name").to_json)
    all_tags_name = raw(Tag.pluck("name").to_json)
    
    tag_box = <<EOF
      <div class="row">
        <div class="col-sm-6">
EOF

    tag_box += "#{text_field_tag id_text_field, instance_text_field, { id: id_text_field, class: 'form-control' } }"
    
    tag_box += <<EOF
        </div>
      </div>

    <script type="text/javascript">

      $("##{id_text_field}").select2({ placeholder: "", tags: #{tag_list}, tokenSeparators: [","] });
      $("##{id_text_field}").bind("change", function() {
        showTagboxAlert("##{id_text_field}", #{unactive_tags_name}, #{all_tags_name}, "#{new_tag_message}");
      });
    </script>
EOF

    return tag_box.html_safe

  end

end
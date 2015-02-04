module TagBoxHelper

  # Return an html div (as String) that handles completion of multiple tag names; it is tipically used in easyadmin
  # to complete tag names in rewards, call to actions, etc.
  def render_html_tag_box(id_text_field, instance_text_field, new_tag_message)
    
    tag_list = raw(Tag.select("name").where("valid_to IS NULL OR valid_to > now()").map(&:name).to_json)
    unactive_tags_name = raw(Tag.where("valid_to < now()").pluck("name").to_json)
    all_tags_name = raw(Tag.pluck("name").to_json)

    property_tags_array = Array.new
    TagsTag.where(:other_tag_id => Tag.find_by_name('property')).each do |tag|
      property_tags_array << Tag.find(tag.tag_id).name
    end
    
    tag_box = "#{text_field_tag id_text_field, instance_text_field, { id: id_text_field, class: 'form-control' } }"
    
    tag_box += <<EOF

    <script type="text/javascript">
      property_tags = 
EOF

    tag_box += "#{property_tags_array.to_json};"

    tag_box += <<EOF

      $("##{id_text_field}").select2({ placeholder: "", tags: #{tag_list}, tokenSeparators: [","] });

      $("##{id_text_field}").on("change", function(e) {
        if(typeof e.added !== 'undefined') {
          $("##{id_text_field}").select2("val", $.map(e.val, function(tag,i) { return tag.toLowerCase(); } ));
        }

        showTagboxAlert("##{id_text_field}", #{unactive_tags_name}, #{all_tags_name}, "#{new_tag_message}");

        colorPropertyTags($('li.select2-search-choice:not(.tag-box-property)').children('div'));
      });

      function colorPropertyTags(divs) {
        divs.each(function() {
          tagName = $(this).text();
          if(property_tags.indexOf(tagName) != -1) {
            $(this).parent('li').removeClass('select2-search-choice').addClass('tag-box-property select2-search-choice');
          }
        });
      };

      $(document).ready(function() {
        colorPropertyTags($('li.select2-search-choice:not(.tag-box-property)').children('div'));
      });

      $.fn.log = function() {
        console.log.apply(console, this);
        return this;
      };
    </script>
EOF

    return tag_box.html_safe

  end

end
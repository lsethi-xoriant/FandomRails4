module CallToActionBoxHelper

  # Return an html div (as String) that handles completion of cta names; it is tipically used in easyadmin
  # to complete cta names in rewards, call to actions, etc.
  def render_html_cta_box(f, id_text_field, call_to_action_id)
    
    cta_box = "#{f.text_field id_text_field}"

    cta_box += <<EOF

      <script type="text/javascript">

      $("##{id_text_field}").select2({ 
        maximumSelectionSize: 1, 
        createSearchChoice: function() { return null; },
        formatNoMatches: function (term) { return "Nessuna Call to Action trovata"; },
        formatSelectionTooBig: function (limit) { return "Puoi selezionare una sola Call to Action"; },
        placeholder: "", 
        tags: #{cta_list}, 
        tokenSeparators: [","] 
      });

      $("##{id_text_field}").on("change", function(e) {
        if(typeof e.added !== 'undefined') {
          $("##{id_text_field}").select2("val", $.map(e.val, function(cta,i) { return cta.toLowerCase(); } ));
        }
      });

    </script>
EOF

    return cta_box.html_safe

  end

end
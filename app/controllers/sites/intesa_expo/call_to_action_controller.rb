class Sites::IntesaExpo::CallToActionController < CallToActionController
  include IntesaExpoHelper


  def cta_has_priority_tag(cta, tag_name)
    priority_tag = get_tag_from_params(tag_name)
    return cta.call_to_action_tags.where("tag_id = ?", priority_tag.id).any?
  end

  def go_to_context(cta, context_name)
    assets = get_tag_from_params("assets")
    assets_extra_fields = assets.extra_fields
    redirect_to "#{assets_extra_fields[context_name]}/call_to_action/#{cta.slug}"
  end

  def show
    cta = CallToAction.active.find(params[:id])
    property = get_intesa_property()
    if property == "imprese"
      if cta_has_priority_tag(cta, "it-priority") 
        go_to_context(cta, "expo_url")
      else
        super
      end
    elsif property == "it"
      if cta_has_priority_tag(cta, "imprese-priority") 
        go_to_context(cta, "imprese_url")
      else
        super
      end
    else
      super

      if property == "inaugurazione"
        @miniformat_color = @calltoaction_info_list[0]["miniformat"]["extra_fields"]["label-background"] rescue nil
      end

    end
  end

end
class Sites::IntesaExpo::CallToActionController < CallToActionController
  include IntesaExpoHelper

  def show
    # When the cta have imprese tag and i'm not in imprese context, i will be redirect in imprese
    if get_intesa_property() == "imprese"
      super
    else
      imprese_tag = get_tag_from_params("imprese")
      cta = CallToAction.active.find(params[:id])
      if cta.call_to_action_tags.where("tag_id = ?", imprese_tag.id).any?
        assets = get_tag_from_params("assets")
        assets_extra_fields = JSON.parse(assets.extra_fields)
        redirect_to "#{assets_extra_fields["imprese_url"]}/call_to_action/#{cta.slug}"
      else
        super
      end
    end
  end

end
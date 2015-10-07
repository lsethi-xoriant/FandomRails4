
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def get_context()
    get_disney_property()
  end

  def expire_user_interaction_cache_keys()
  end

  def append_calltoaction
    tag_name = get_disney_property()
    params[:page_elements] = ["like", "comment", "share"]
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, 6)
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def ordering_ctas
    tag_name = get_disney_property()
    params[:page_elements] = ["like", "comment", "share"]

    if params["other_params"]
      params["other_params"] = JSON.parse(params["other_params"])
    end
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, $site.init_ctas)
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

end
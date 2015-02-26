class Sites::Disney::BrowseController < BrowseController
  include DisneyHelper
  
  # hook to redirect to browse on the base of current property
  def go_to_browse
    redirect_to "#{get_disney_property_root_path}/browse"
  end
  
  def get_not_found_message(query)
    if get_disney_property == "disney-channel"
      "Non ci sono risultati per la tua ricerca '#{query}'."
    else
      "Non ci sono risultati per la tua ricerca '#{query}'.<br/> Prova a cercare su <a href='javascript:void(0);' onclick=\"serchRedirect('#{query}')\">DisneyChannel</a>"
=begin
      response = "Non ci sono risultati per la tua ricerca '#{query}'.<br/> Prova a cercare su "
      properties = get_tags_with_tag("property")
      properties.each do |p|
        
        if get_disney_property != p.name
          if p.name != "disney-channel"
            response = response + "<a href='#{get_disney_root_path_for_property_name(p.name)}/browse'>#{p.title}</a> "
          else
            response = response + "<a href='/browse'>#{p.title}</a> "
          end
        end
        
      end
      response 
=end
    end
  end
  
  def get_search_cache_key_params(term)
    "#{term}_#{get_disney_property}"
  end
  
  def get_search_tags_for_tenant
    if get_disney_property == "disney-channel" 
      []
    else
      [Tag.find_by_name(get_disney_property)]
    end
  end
  
  # hook for filter content with current property
  def get_tags_for_category(tag)
    if get_disney_property == "disney-channel" 
      [tag]
    else
      [tag, Tag.find_by_name(get_disney_property)]
    end
  end
  
  #hook for filter search result in specific property if multiproperty site
  def get_current_property
    property = get_disney_property
    if property == "disney_channel"
      nil
    else
      property
    end
  end
  
end
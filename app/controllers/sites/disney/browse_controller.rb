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
    end
  end
  
  def get_search_cache_key_params(term)
    "#{term}_#{get_disney_property}"
  end
  
end
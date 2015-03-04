class Sites::Orzoro::BrowseController < BrowseController
  include OrzoroHelper
  
  # hook to redirect to browse on the base of current property
  def go_to_browse
    redirect_to "/browse/search"
  end
  
  def get_not_found_message(query)
    "La tua ricerca non ha prodotto risultati."
  end
  
end
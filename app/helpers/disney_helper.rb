module DisneyHelper
  def get_disney_property() 
    $context_root || "disney-channel"
  end
end

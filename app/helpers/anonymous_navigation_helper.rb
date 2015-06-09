module AnonymousNavigationHelper
  
  def interaction_for_anonymous?(resource_type)
    $site.interactions_for_anonymous.present? && $site.interactions_for_anonymous.include?(resource_type)
  end

end

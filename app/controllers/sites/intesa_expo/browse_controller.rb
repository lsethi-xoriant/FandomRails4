class Sites::IntesaExpo::BrowseController < BrowseController
  include IntesaExpoHelper
  
  def intesa_index_category
    # call index category of parent class to personalize intesa index category page with further information and
    # display settings
    index_category
    
    extra_fields = get_extra_fields!(@category)
    @aux_other_params = {}
    
    if extra_fields['top_stripe']
      @aux_other_params['top_stripe'] = get_content_preview_stripe(extra_fields['top_stripe']) 
    end
    
    if extra_fields['bottom_stripe']
      @aux_other_params['bottom_stripe'] = get_content_preview_stripe(extra_fields['bottom_stripe']) 
    end
    
    @use_filter = extra_fields['use_filter'].nil? ? false : extra_fields['use_filter']['value']
    
  end
  
end
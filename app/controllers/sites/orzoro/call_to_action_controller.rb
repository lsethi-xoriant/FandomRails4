class Sites::Orzoro::CallToActionController < CallToActionController

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      calltoaction: calltoaction
    }
  end

  def append_calltoaction_page_elements
    ["empty"]
  end

end
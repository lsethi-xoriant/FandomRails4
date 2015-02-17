
class Sites::Orzoro::CallToActionController < CallToActionController

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      calltoaction: calltoaction
    }
  end

end
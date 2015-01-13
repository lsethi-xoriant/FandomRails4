
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def build_current_user() 
    build_disney_current_user()
  end

  def get_context()
    get_disney_property()
  end

  def init_show_aux()
    current_property = get_tag_from_params(get_disney_property())
    disney_default_aux(current_property, init_captcha: true);
  end

end
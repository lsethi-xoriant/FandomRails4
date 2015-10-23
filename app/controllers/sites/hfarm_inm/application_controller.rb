class Sites::HfarmInm::ApplicationController < ApplicationController

  def index
    _params = {}
    tag_name = "ilnostromomento"

    @calltoaction_info_list, @has_more = get_ctas_for_stream(tag_name, _params, $site.init_ctas)

    @aux_other_params = { 
    }
  end
  
end
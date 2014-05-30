require 'fandom_utils'
include FandomUtils

module MaxibonUtils

  class Matcher
    def matches?(request)
      referer_is_facebook = (request.env['HTTP_REFERER']=~/facebook\.com|maxibon\.it/).to_f > 0
      is_mobile = mobile_device? request
      return !referer_is_facebook && !is_mobile      
    end
  end
    
end
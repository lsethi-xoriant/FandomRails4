class HttpErrorController < ApplicationController

  def not_found_404
    return_error(404, 'page not found')
  end
  
  def internal_error_500
    return_error(500, 'something bad happened')
  end
  
  def unprocessable_entity_422
    return_error(422, 'unprocessable entity')
  end

  def return_error(http_status, message)
    # force errors in json format if path is detected to be related to api, because format handling apparently doesn't work here
    if env["REQUEST_PATH"] =~ /^(\/[a-zA-Z_0-9]+)?\/api\//
      render json: { error_code: http_status, error_message: message, errors: [message] }
    else
      respond_to do |format|
        format.html { render status: http_status }
        format.json { render json: { error_code: http_status, error_message: message, errors: [message] } }
      end
    end
  end

end

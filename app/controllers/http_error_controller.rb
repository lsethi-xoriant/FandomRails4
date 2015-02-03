class HttpErrorController < ApplicationController

  def not_found_404
    #return_error(404, 'page not found')
  end
  
  def internal_error_500
    return_error(500, 'something bad happened')
  end
  
  def unprocessable_entity_422
    return_error(422, 'unprocessable entity')
  end

  def return_error(code, message)
    respond_to do |format|
      format.html
      format.json { render json: { error_code: code, error_message: message } }
    end
  end

end

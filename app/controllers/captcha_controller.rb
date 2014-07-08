class CaptchaController < ApplicationController  
  include CaptchaHelper
  
  def generate_captcha
    response = generate_captcha_response

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

end

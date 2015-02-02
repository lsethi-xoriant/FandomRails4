class CaptchaController < ApplicationController  
  include CaptchaHelper
  
  def generate_captcha
    response = []
    interaction_info_list = params[:interaction_info_list]
    
    if interaction_info_list
      interaction_info_list.each do |interaction|
        interaction = JSON.parse(interaction)
        response << {
          "calltoaction_id" => interaction["calltoaction_id"],
          "interaction_id" => interaction["interaction_id"],
          "captcha" => generate_captcha_response
        }.to_json
      end
    end

    respond_to do |format|
      format.json { render json: response }
    end
  end

end

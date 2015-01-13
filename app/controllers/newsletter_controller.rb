require 'fandom_utils'

class NewsletterController < ApplicationController

  def unsubscribe
    if params[:security_token] == Digest::MD5.hexdigest(params[:email] + Rails.configuration.secret_token)
      user = User.find_by_email(params[:email])
      if user.newsletter
        user.update_attribute(:newsletter, false)
        flash[:notice] = "Indirizzo rimosso dalla newsletter"
      else
        flash[:notice] = "L'indirizzo non risulta iscritto alla newsletter"
      end
    else
      flash[:notice] = "Link non valido"
    end
  end

end
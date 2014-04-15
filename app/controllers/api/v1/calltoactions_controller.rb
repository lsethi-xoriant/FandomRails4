 class Api::V1::CalltoactionsController < ApplicationController
    #doorkeeper_for :all # Per autorizzare un contenuto
    before_filter :check_application_client

    respond_to :json

    def index
      	respond_with Calltoaction.active.to_json({ include: :interactions, methods: [:image_url] })
    end

    def show
    	calltoaction = Calltoaction.find(params[:calltoaction_id])		

    	calltoaction_json = Hash.new
    	calltoaction_json[:calltoaction] = Hash.new
    	calltoaction.interactions.each do |i|
    		calltoaction_json[:calltoaction][:interactions] = i
    		calltoaction_json[:calltoaction][:interactions][:resource] = i.resource
    		calltoaction_json[:calltoaction][:interactions][:resource][:asnwers] = i.resource.answers if i.resource_type == "Quiz" 
    		if doorkeeper_token
    			calltoaction_json[:calltoaction][:interactions][:resource][:user_info] = i.userinteractions.where(user_id: doorkeeper_token.resource_owner_id)
    		end
    	end
    	calltoaction_json[:calltoaction][:info] = calltoaction #,{ points: "AAABBB" }

		respond_with calltoaction_json
    end

    # TODO: assegnazione di un userinteraction ad un utente loggato.

end
class RssController < ApplicationController
	
  	def property_rss
  		@current_prop = Property.find(params[:property_id])
	  	@calltoaction_list = Calltoaction.active.where("property_id=?", @current_prop.id).order("activated_at DESC").limit(10)
	  	respond_to do |format|
	    	format.rss { render :layout => false }
	  	end
	end

	def global_rss
	  	@calltoaction_list = Calltoaction.active.order("activated_at DESC").limit(10)
	  	respond_to do |format|
	    	format.rss { render :layout => false }
	  	end
	end

end

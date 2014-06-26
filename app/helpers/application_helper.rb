require 'fandom_utils'

module ApplicationHelper

	def counter_about_user_reward(reward)
		user_reward = current_user_or_anonymous_user.user_rewards.includes(:reward).where("rewards.name='#{reward}'").first
		user_reward ? user_reward.counter : 0
	end

	def interaction_answer_percentage(interaction, answer)
		interaction_answers_count = interaction.user_interactions.count
		interaction_current_answer_count = interaction.user_interactions.where("answer_id = ?", answer.id).count
		return (interaction_current_answer_count.to_f / interaction_answers_count.to_f) * 100
	end

	def current_user_or_anonymous_user
		current_user.present? ? current_user : User.find_by_email("anonymous@shado.tv")
	end
	
	def mobile_device?()
	  FandomUtils::request_is_from_mobile_device?(request)
	end

	def ipad?
		return request.user_agent =~ /iPad/ 
	end

	def interaction_play_for_calltoaction(calltoaction)
		calltoaction.interactions.find_by_resource_type('Play')
	end

	def calltoaction_active_with_tag(tag, order)
		return CallToAction.includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at<=? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name='#{tag}')", Time.now).order("activated_at #{order}")
	end

	def calltoaction_coming_soon_with_tag(tag, order)
		return CallToAction.includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at>? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name='#{tag}')", Time.now).order("activated_at #{order}")
	end 

	def calltoactions_except_share(calltoaction)
		calltoactions_except_share = cache_short("calltoactions_except_share_#{calltoaction.id}") do
		  calltoaction.interactions.where("resource_type<>'Share'").to_a
		end
	end

	def calltoaction_interaction_share_done?(calltoaction)
	  done = true
	  if current_user
	    calltoactions_just_share = cache_short("calltoactions_just_share_#{calltoaction.id}") do
	      calltoaction.interactions.where("resource_type='Share'").to_a
	    end	    
	    done = false if current_user.user_interactions.where("interaction_id in (?)", calltoactions_just_share.map.collect { |u| u["id"] }).blank?
		else
			done = false
		end 
	  return done
	end

	def calltoaction_done?(calltoaction)
		# Check if user completed calltoaction.
	  done = true
	  if current_user
	  		# TODO: when_show_interaction!='MAI_VISIBILE'
	  		calltoactions_except_share = calltoactions_except_share(calltoaction)
	  		
		    calltoactions_except_share.each do |i|
		      done = false if UserInteraction.where("interaction_id=? AND user_id=?", i.id, current_user.id).blank?
		    end

		    calltoactions_just_share = cache_short("calltoactions_just_share_#{calltoaction.id}") do
		      calltoaction.interactions.where("resource_type='Share'").to_a
		    end
		    
		    done = false if current_user.user_interactions.where("interaction_id in (?)", calltoactions_just_share.map.collect { |u| u["id"] }).blank?
		else
			done = false
		end 
	   return done
	end

	def user_points_except_share_for(calltoaction)
		calltoactions_except_share_with_user_interactions = calltoaction.interactions.includes(:user_interactions).where("interactions.resource_type<>'Share'")
		# TODO: update with new reward system
		#user_points = calltoactions_except_share_with_user_interactions.where("user_interactions.user_id=?", current_user).sum("user_interactions.points")
		#user_points = user_points + calltoactions_except_share_with_user_interactions.where("user_interactions.user_id=?", current_user).sum("user_interactions.added_points")
		0
	end

	def calltoaction_except_share_done?(calltoaction)
		# Check if user completed calltoaction.
	  done = true
	  if current_user
	  		# TODO: when_show_interaction!='MAI_VISIBILE'
	  		calltoactions_except_share = calltoactions_except_share(calltoaction)
	  		
		    calltoactions_except_share.each do |i|
		      done = false if UserInteraction.where("interaction_id=? AND user_id=?", i.id, current_user.id).blank?
		    end
		else
			done = false
		end 
	    return done
	end

	def current_avatar size = "normal"
		# Ritorna l'indirizzo dell'avatar corrente.
		if current_user
			return user_avatar current_user
		else
			return "/assets/anon.png"
		end
	end

	def user_avatar user, size = "normal"
		# Ritorna l'indirizzo dell'avatar associato all'utente specificato.
		case user.avatar_selected
		when "upload"
			avatar = user.avatar ? user.avatar(:thumb) : "/assets/anon.png"
		when "facebook"
			avatar = user.authentications.find_by_provider("facebook").avatar
		when "twitter"
			avatar = user.authentications.find_by_provider("twitter").avatar.gsub("_normal","_#{ size }")
		end
		return avatar
	end

	def disqus_sso
		if current_user && ENV['DISQUS_SECRET_KEY'] && ENV['DISQUS_PUBLIC_KEY']
  		user = current_user
	    data = {
	      	'id' => user.id,
	      	'username' => "#{ user.first_name } #{ user.last_name }",
	      	'email' => user.email,
	     	'avatar' =>  current_avatar
	        # 'url' => user.url
	    }.to_json
	 
	    message = Base64.encode64(data).gsub("\n", "") # Encode the data to base64.    
	    timestamp = Time.now.to_i # Generate a timestamp for signing the message.
	    sig = OpenSSL::HMAC.hexdigest('sha1', ENV['DISQUS_SECRET_KEY'], '%s %s' % [message, timestamp]) # Generate our HMAC signature
	 
		 	x = 
		 		"<script type=\"text/javascript\">" +
					"var disqus_config = function() {" +
					"this.page.remote_auth_s3 = \"#{ message } #{ sig } #{ timestamp }\";" +
					"this.page.api_key = \"#{ ENV['DISQUS_PUBLIC_KEY'] }\";" +
					"this.sso = {" +
				          "name:   \"SampleNews\"," +
				          "button:  \"http://placehold.it/50x50\"," +
				          "icon:     \"http://placehold.it/50x50\"," +
				          "url:        \"http://example.com/login/\"," +
				          "logout:  \"http://example.com/logout/\"," +
				          "width:   \"800\"," +
				          "height:  \"400\"" +
				    "};" +
					"}" +
		    "</script>"
	    
			return x
		else
			return "DISQUS debugger: user not logged or wrong keys."
		end
   	end

	def calculate_month_string_ita(month_number)
	    case month_number
	      when 1
	        return "gennaio"
	      when 2
	        return "febbraio"
	      when 3
	        return "marzo"
	      when 4
	        return "aprile"
	      when 5
	        return "maggio"
	      when 6
	        return "giugno"
	      when 7
	        return "luglio"
	      when 8
	        return "agosto"
	      when 9
	        return "settembre"
	      when 10
	        return "ottobre"
	      when 11
	        return "novembre"
	      when 12
	        return "dicembre"
	      else
	        return ""
	    end
  	end

  def calltoactions_totalpoints(calltoaction)
    cache_short("calltoactions_totalpoints_#{calltoaction.id}") do
      # TODO: update with new reward system
      #totalpoints = calltoaction.interactions.where("resource_type<>'Share'").sum("points")
      #totalpoints = totalpoints + calltoaction.interactions.where("resource_type<>'Share'").sum("added_points")
    	0

    	# Not include share interactions points.
      # inter_share = calltoaction.interactions.where("resource_type='Share'")
      # totalpoints = totalpoints + inter_share.maximum("points") if inter_share.count > 0
    end
  end

  def calltoactions_share_points(calltoaction)
  	cache_short("calltoactions_share_points_#{calltoaction.id}") do
  		# TODO: update with new reward system
  		#inter_share = calltoaction.interactions.where("resource_type='Share'")
  		#share_points = (inter_share.any? ? inter_share.maximum("points") : 0)
  		return 0
  	end
  end

  def all_share_interactions(calltoaction)
    cache_short("all_share_interactions_#{calltoaction.id}") do
      calltoaction.interactions.where("resource_type='Share'").to_a
    end
  end

end

module ApplicationHelper
	
	def mobile_device?
		iphone = request.user_agent =~ /iPhone/ 
		mobile = request.user_agent =~ /Mobile/
		android = request.user_agent =~ /Android/  

		# Mobile and Android identifica il MOBILE di tipo Android, altrimenti con solo Android abbiamo il TABLET.
		return !(iphone || (mobile && android)		)
	end

	def ipad?
		return request.user_agent =~ /iPad/ 
	end

	def calltoaction_done? calltoaction
		# Restituisce se la calltoaction e' gia' stata terminata.
	    done = true
	    if current_user
		    calltoaction.interactions.where("points>0 AND when_show_interaction!='MAI_VISIBILE'").each do |i|
		      done = false if Userinteraction.where("interaction_id=? AND user_id=?", i.id, current_user.id).blank?
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
		 
		 	x = "<script type=\"text/javascript\">" +
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
			return "DISQUS debugger: utente non loggato o chiavi DISQUS non salvate correttamente"
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

end

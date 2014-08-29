#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

module ApplicationHelper
  
  include RewardingSystemHelper
  
  class BrowseCategory
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    # human readable name of this field
    attribute :title, type: String
    # html id of this field
    attribute :id, type: String
    attribute :has_thumb, type: Boolean
    attribute :thumb_url, type: String
    attribute :description, type: String
    attribute :long_description, type: String
    attribute :detail_url, type: String
    attribute :created_at, type: Integer
    attribute :header_image_url, type: String
    attribute :icon_url, type: String
  end

  class ContentSection
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    # key can be either tag name or special keyword such as $recent
    attribute :key, type: String
    attribute :title, type: String
    attribute :contents
    attribute :view_all_link, type: String
    attribute :column_number, type: Integer
  end

  def interaction_done?(interaction)
    return current_user && UserInteraction.find_by_user_id_and_interaction_id(current_user.id, interaction.id)
  end

  def get_tag_to_rewards()
  	cache_short("tag_to_rewards") do
  		tag_to_rewards = Hash.new
		  RewardTag.all.each do |reward_tag|
		  	unless tag_to_rewards.key? reward_tag.tag.name
		  		tag_to_rewards[reward_tag.tag.name] = Set.new 
		  	end
		  	tag_to_rewards[reward_tag.tag.name] << reward_tag.reward 
		  end
		  tag_to_rewards
		end
  end

	def get_tag_with_tag_about_call_to_action(calltoaction, tag_name)
		Tag.includes(tags_tags: :other_tag).includes(:call_to_action_tags).where("other_tags_tags_tags.name = ? AND call_to_action_tags.call_to_action_id = ?", tag_name, calltoaction.id)
	end

	def get_tags_with_tag(tag_name)
		Tag.includes(tags_tags: :other_tag).where("other_tags_tags_tags.name = ?", tag_name)
	end

  def get_ctas_with_tag(tag_name)
    CallToAction.active.includes(call_to_action_tags: :tag).where("tags.name = ?", tag_name)
  end

	def get_user_interaction_from_interaction(interaction, user)
		user.user_interactions.find_by_interaction_id(interaction.id)
	end

  def push_in_array(array, element, push_times)
    push_times.times do
      array << element
    end
  end

  # Generates an hash with reward information.
	def get_current_call_to_action_reward_status(reward_name, calltoaction)
    reward = Reward.find_by_name(reward_name)

    empty_user = User.new

    max_outcome = predict_max_cta_outcome(calltoaction, empty_user)
    max_outcome_and_interaction = max_outcome[1].zip(max_outcome[2])

    reward_status_images = Array.new
    winnable_reward_count = 0

    max_outcome_and_interaction.each do |outcome, interaction|
      total_reward_count = outcome["reward_name_to_counter"][reward_name]
      
      if current_user
        user_interaction = interaction.user_interactions.find_by_user_id(current_user.id)
        if user_interaction
          win_reward_count = JSON.parse(user_interaction.outcome)["attributes"]["reward_name_to_counter"].fetch(reward_name, 0)
          push_in_array(reward_status_images, reward.preview_image(:thumb), win_reward_count)
          push_in_array(reward_status_images, reward.not_winnable_image(:thumb), (total_reward_count - win_reward_count))
        else 
          winnable_reward_count += total_reward_count
          push_in_array(reward_status_images, reward.not_awarded_image(:thumb), total_reward_count)
        end
      else
        push_in_array(reward_status_images, reward.not_awarded_image(:thumb), total_reward_count)
      end

    end

    {
      all_reward_count: max_outcome[0]["reward_name_to_counter"][reward_name],
      winnable_reward_count: winnable_reward_count,
      reward_status_images: reward_status_images,
      reward: Reward.find_by_name(reward_name)
    }

	end

  def get_current_interaction_reward_status(reward_name, interaction)
    reward = Reward.find_by_name(reward_name)

    empty_user = User.new

    total_reward_count = predict_outcome(interaction, empty_user, true).reward_name_to_counter[reward_name]
    if current_user
      winnable_reward_count = predict_outcome(interaction, current_user, true).reward_name_to_counter[reward_name]
      user_interaction = current_user.user_interactions.find_by_interaction_id(interaction.id)
    else
      winnable_reward_count = total_reward_count
    end

    reward_status_images = Array.new 
      
    if current_user && user_interaction
      outcome = JSON.parse(user_interaction.outcome)
      win_reward_count = outcome["attributes"]["reward_name_to_counter"][reward_name]      
      push_in_array(reward_status_images, reward.preview_image(:thumb), win_reward_count)
      push_in_array(reward_status_images, reward.not_winnable_image(:thumb), (total_reward_count - win_reward_count))
    else
      push_in_array(reward_status_images, reward.not_awarded_image(:thumb), total_reward_count)
    end

    {
      reward_status_images: reward_status_images,
      reward: reward
    }

  end

	def get_counter_about_user_reward(reward_name)
		user_reward = current_or_anonymous_user.user_rewards.includes(:reward).where("rewards.name = '#{reward_name}'").first
		user_reward ? user_reward.counter : 0
	end

	def user_has_reward(reward_name)
		current_or_anonymous_user.user_rewards.includes(:reward).where("rewards.name = '#{reward_name}'").any?
	end

	def compute_rewards_gotten_over_total(reward_ids)
		if reward_ids.any?
		  place_holders = (["?"] * reward_ids.count).join ", "
			current_or_anonymous_user.user_rewards.where("reward_id IN (#{place_holders})", *reward_ids).count
		else
			0
		end
	end

	def interaction_answer_percentage(interaction, answer)
		interaction_answers_count = interaction.user_interactions.count
		interaction_current_answer_count = interaction.user_interactions.where("answer_id = ?", answer.id).count
		return ((interaction_current_answer_count.to_f / interaction_answers_count.to_f) * 100).round
	end

	def anonymous_user
		User.find_by_email("anonymous@shado.tv")
	end

	def current_or_anonymous_user
		current_user.present? ? current_user : anonymous_user
	end
	
	def mobile_device?()
	  FandomUtils::request_is_from_mobile_device?(request)
	end

	def ipad?
		return request.user_agent =~ /iPad/ 
	end

	def find_interaction_for_calltoaction_by_resource_type(calltoaction, resource_type)
		calltoaction.interactions.find_by_resource_type(resource_type)
	end

	def calltoaction_active_with_tag(tag, order)
		return CallToAction.includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at<=? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name=?)", Time.now, tag).order("activated_at #{order}")
	end

	def calltoaction_coming_soon_with_tag(tag, order)
		return CallToAction.includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at>? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name=?)", Time.now, tag).order("activated_at #{order}")
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
  
  def compute_save_and_notify_outcome(userinteraction, user_upload_interaction)
    outcome = compute_and_save_outcome(userinteraction)
    outcome.reward_name_to_counter.each do |r|
      reward = Reward.find_by_name(r.first)
      html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_template", locals: { icon: reward.preview_image, title: reward.title }, layout: false, formats: :html
      notice = Notice.create(:user_id => user_upload_interaction.user_id, :html_notice => html_notice, :viewed => false, :read => false)
      notice.send_to_user(request)
    end
  end
  
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end
  
end

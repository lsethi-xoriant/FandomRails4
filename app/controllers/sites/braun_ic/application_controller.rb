class Sites::BraunIc::ApplicationController < ApplicationController
  
  def reset_redo_user_interactions
    cta = CallToAction.find(params[:parent_cta_id])
    category_tag = get_cta_tag_tagged_with(cta, "test")
    
    update_user_points(category_tag)

    user_interactions = UserInteraction.where(id: params[:user_interaction_ids]).order(created_at: :desc)
    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      aux["to_redo"] = true
      user_interaction.update_attributes(aux: aux)
    end

    response = {
      calltoaction_info: build_cta_info_list_and_cache_with_max_updated_at([cta]).first
    }

    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def update_user_points(category_tag)
    reward_name = "#{category_tag.name}-point"
    point_reward = current_user.user_rewards.includes(:reward).where("rewards.name = ?", reward_name).references(:rewards).first
    points = point_reward.counter

    ActiveRecord::Base.transaction do
      user_reward = current_user.user_rewards.includes(:reward).where("rewards.name = 'point'").references(:rewards).first
      user_reward.update_attribute(:counter, (user_reward.counter - points))
    end

    point_reward.destroy
  end

  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?

    cta_id = params[:id]
    descendent_id = params[:descendent_id]

    params = { "page_elements" => ["quiz", "share"] }
    @calltoaction_info_list, @has_more = get_ctas_for_stream("test", params, 15)

    cta_ids = @calltoaction_info_list.map { |cta_info| cta_info["calltoaction"]["id"] }
    
    badge_tag = Tag.find("badge")
    ctas = CallToAction.where(id: cta_ids)

    badges = {}
 
    @calltoaction_info_list.each do |cta_info|
      cta = find_in_calltoactions(ctas, cta_info["calltoaction"]["id"])
      
      category_tag = get_cta_tag_tagged_with(cta, "test")
      reward_ids = get_rewards_with_tags_in_and([category_tag, badge_tag]).map { |r| r.id }

      rewards = Reward.includes(:user_rewards).where("rewards.id IN (?)", reward_ids)
      if current_user
        reward = rewards.where("user_rewards.user_id = ?", current_user.id).references(:user_rewards).order(cost: :desc).first
        if reward
          inactive = false
        else
          reward = rewards.order(cost: :asc).first 
          inactive = true
        end
      else
        reward = rewards.order(cost: :asc).first
        inactive = true
      end

      badges[get_parent_cta_name(cta_info)] = adjust_braun_ic_reward(reward, inactive, get_parent_cta(cta_info)["calltoaction"]["activated_at"])
    end

    if cta_id
      cta = CallToAction.find(cta_id)
      set_seo_info_for_cta(cta)
      anchor_to = cta.slug
      compute_seo()
      if descendent_id
        calltoaction_to_share = CallToAction.find(descendent_id)
        extra_fields = calltoaction_to_share.extra_fields

        image = strip_tags(extra_fields["linked_result_image"]["url"]) rescue nil

        update_seo_value(strip_tags(extra_fields["linked_result_title"]), "title")
        update_seo_value(strip_tags(extra_fields["linked_result_description"]), "meta_description")
        update_seo_value(image, "meta_image")
      end
    else 
      compute_seo()
    end

    params = { "page_elements" => ["share"] }
    tip_info_list, has_more_tips = get_ctas_for_stream("tip", params, 3)
    product_info_list, has_more_products = get_ctas_for_stream("product", params, 15)

    @aux_other_params = { 
      anchor_to: anchor_to,
      tag_menu_item: "home",
      badges: badges,
      tips: {
        tip_info_list: tip_info_list,
        has_more: has_more_tips
      },
      products: {
        product_info_list: product_info_list,
        has_more: has_more_products
      }
    }
  end

  def append_tips
    params[:page_elements] = ["share"]
    calltoaction_info_list, has_more = get_ctas_for_stream(params[:tag_name], params, 3)

    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

end
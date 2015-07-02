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
    
    params = { "page_elements" => ["quiz", "share"] }
    @calltoaction_info_list, @has_more = get_ctas_for_stream(nil, params, $site.init_ctas)

    cta_ids = @calltoaction_info_list.map { |cta_info| cta_info["calltoaction"]["id"] }
    
    badge_tag = Tag.find("badge")
    ctas = CallToAction.where(id: cta_ids)
    
    # TODO: optimize with one query
    @calltoaction_info_list.each do |cta_info|
      cta = find_in_calltoactions(ctas, cta_info["calltoaction"]["id"])
      
      category_tag = get_cta_tag_tagged_with(cta, "test")
      reward_ids = get_rewards_with_tags_in_and([category_tag, badge_tag]).map { |r| r.id }

      rewards = Reward.includes(:user_rewards).where("rewards.id IN (?)", reward_ids)
      if current_user
        reward = rewards.where("user_rewards.user_id = ?", current_user.id).references(:user_rewards).order(cost: :desc).first
        reward = rewards.order(cost: :asc).first unless reward
      else
        reward = rewards.order(cost: :asc).first
      end

      cta_info[:reward] = {
        name: reward.name,
        image: reward.main_image,
        cost: reward.cost
      }
    end

    @aux_other_params = { 
      tag_menu_item: "home"
    }
  end

end
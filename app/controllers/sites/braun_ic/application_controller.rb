class Sites::BraunIc::ApplicationController < ApplicationController
  
  before_filter :only_registered_user, only: [:contest_identitycollection, :contest_identitycollection_update]

  def only_registered_user
    unless registered_user?
      redirect_to "/users/sign_up"
    end
  end

  class ContestIdentityCollectionUser
    include ActiveAttr::Attributes
    include ActiveAttr::Model

    attribute :first_name, type: String
    attribute :last_name, type: String
    attribute :receipt_number, type: String
    attribute :day_of_emission, type: String
    attribute :month_of_emission, type: String
    attribute :year_of_emission, type: String
    attribute :product_code, type: String

    validates_presence_of :first_name, :last_name, :receipt_number, :product_code
    validate :date_of_emission
    
    def date_of_emission
      if day_of_emission.blank? || month_of_emission.blank? || year_of_emission.blank?
        errors.add(:date_of_emission, "non può essere lasciata in bianco")
      end
    end                      
  end

  def contest
    badges = compute_user_badge(current_user.id) if registered_user?
    @aux_other_params = { 
      badges: badges
    }
  end 

  def contest_identitycollection
    @contest_identitycollection_user = ContestIdentityCollectionUser.new(
      first_name: current_user.first_name, 
      last_name: current_user.last_name
    )
  end 

  def contest_identitycollection_update
    user_params = params[:sites_braun_ic_application_controller_contest_identity_collection_user]
    @contest_identitycollection_user = ContestIdentityCollectionUser.new(user_params)
    if @contest_identitycollection_user.valid?
      aux = current_user.aux || {}

      day_of_emission = user_params[:day_of_emission]
      month_of_emission = user_params[:month_of_emission]
      year_of_emission = user_params[:year_of_emission]

      (aux["products"] ||= []) << {
        receipt_number: user_params[:receipt_number],
        product_code: user_params[:product_code],
        date_of_emission: "#{year_of_emission}/#{month_of_emission}/#{day_of_emission}"
      }

      if current_user.update_attributes(first_name: user_params[:first_name],
        last_name: user_params[:last_name], aux: aux)
        flash[:notice] = "Dati salvati correttamente"
        redirect_to "/concorso_identitycollection#contest_identitycollection_user_form"
      else
        flash[:error] = "Errore nel salvataggio, scrivi a support@shado.tv"
        log_error("contest_identitycollection_update", { exception: current_user.errors.to_s }) 
        redirect_to "/concorso_identitycollection#contest_identitycollection_user_form"
      end
    else
      render template: "application/contest_identitycollection"
    end
  end

  def reset_redo_user_interactions
    cta = CallToAction.find(params[:parent_cta_id])
    category_tag = get_cta_tag_tagged_with(cta, "test")
    
    inactive_reward = update_user_points(category_tag)

    user_interactions = UserInteraction.where(id: params[:user_interaction_ids]).order(created_at: :desc)
    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      aux["to_redo"] = true
      user_interaction.update_attributes(aux: aux)
    end

    response = {
      calltoaction_info: build_cta_info_list_and_cache_with_max_updated_at([cta]).first,
      badge: adjust_braun_ic_reward(inactive_reward, true, cta.activated_at)
    }

    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def update_user_points(category_tag)
    reward_name = "#{category_tag.name}-point"
    point_reward = current_user.user_rewards.includes(:reward).where("rewards.name = ?", reward_name).references(:rewards).first
    points = point_reward.present? ? point_reward.counter : 0

    ActiveRecord::Base.transaction do
      user_reward = current_user.user_rewards.includes(:reward).where("rewards.name = 'point'").references(:rewards).first
      if user_reward
        user_reward.update_attribute(:counter, (user_reward.counter - points))
      end
    end

    badge_tag = Tag.find("badge")
    rewards = get_rewards_with_tags_in_and([category_tag, badge_tag])
    user_rewards = current_user.user_rewards.where(reward_id: rewards.map { |r| r.id }).order(counter: :asc)
    
    user_rewards.destroy_all if user_rewards.any?
    point_reward.destroy if point_reward

    rewards.first
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

    product_info_list, has_more_products = get_ctas_for_stream("product", params, 15)
    if cta_id
      cta = CallToAction.find(cta_id)

      tip_tag = Tag.find("tip")
      is_cta_tagged_with_tip = CallToActionTag.where(call_to_action_id: cta.id, tag_id: tip_tag.id).any?
      if is_cta_tagged_with_tip
        top_cta_info = build_cta_info_list_and_cache_with_max_updated_at([cta], ["share"])
      end

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
    if top_cta_info.present?
      exclude_cta_with_ids = [top_cta_info[0]["calltoaction"]["id"]]
      params = { "page_elements" => ["share"], "exclude_cta_with_ids" => exclude_cta_with_ids }
      tip_cta_limit = 2
    else
      params = { "page_elements" => ["share"] }
      tip_cta_limit = 3
    end

    tip_info_list, has_more_tips = get_ctas_for_stream("tip", params, tip_cta_limit)
    
    if top_cta_info.present?
      tip_info_list = top_cta_info + tip_info_list
    end

    @aux_other_params = { 
      anchor_to: anchor_to,
      exclude_cta_with_ids: exclude_cta_with_ids,
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
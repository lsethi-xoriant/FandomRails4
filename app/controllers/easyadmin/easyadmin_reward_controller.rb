class Easyadmin::EasyadminRewardController < ApplicationController
  include EasyadminHelper

  layout "admin"

  def index
    @reward_list = Reward.order("cost ASC")
  end

  def new
    @reward = Reward.new
    @currency_rewards = Reward.where("spendable = TRUE")
  end

  def save
    @reward = Reward.create(params[:reward])
    tag_list = params[:tag_list].split(",")
    if @reward.errors.any?
      @tag_list = tag_list
      render template: "/easyadmin/easyadmin/new_reward"     
    else
      @reward.update_attribute(:currency_id,params[:currency_id])
      update_and_redirect(tag_list, "Reward generato correttamente", @reward)
    end
  end

  def edit
    @reward = Reward.find(params[:id])
    @currency_rewards = Reward.where("spendable = TRUE")
    @tag_list = get_reward_tag_list(@reward)
  end
  
  def update
    @reward = Reward.find(params[:id])
    tag_list = params[:tag_list].split(",")
    unless @reward.update_attributes(params[:reward])
      @tag_list = tag_list
      render template: "/easyadmin/easyadmin/edit_reward"   
    else
      @reward.update_attribute(:currency_id,params[:currency_id])
      update_and_redirect(tag_list, "Reward aggiornato correttamente", @reward)
    end
  end

  def update_and_redirect(tag_list, flash_message, reward)
    update_reward_tag(tag_list,reward)
    flash[:notice] = flash_message
    redirect_to "/easyadmin/reward/show/#{ reward.id }"
  end
  
  def show
    @current_reward = Reward.find(params[:id])
    @tag_list = get_reward_tag_list(@current_reward)
  end
  
  def get_reward_tag_list(reward)
    tag_list_arr = Array.new
    reward.reward_tags.each { |t| tag_list_arr << t.tag.name }
    return tag_list = tag_list_arr.join(",")
  end
  
  def update_reward_tag(tag_list, reward)
    reward.reward_tags.delete_all
    tag_list.each do |t|
      tag = Tag.find_by_text(t)
      tag = Tag.create(text: t) unless tag
      RewardTag.create(tag_id: tag.id, reward_id: @reward.id)
    end
  end
end
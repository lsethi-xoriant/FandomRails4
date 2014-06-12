class Easyadmin::EasyadminRewardController < ApplicationController
  include EasyadminHelper

  layout "admin"

  MEDIA_TYPE = ["VIDEO","DIGITAL PRIZE"]


  def index
    @reward_list = Reward.order("cost ASC")
  end

  def new
    @reward = Reward.new
    @currency_awards = Reward.where("spendable = TRUE")
  end

  def save
    @reward = Reward.create(params[:reward])
    
    if @reward.errors.any?
      @tag_list = params[:tag_list].split(",")

      render template: "/easyadmin/easyadmin/new_reward"     
    else

      tag_list = params[:tag_list].split(",")
      @reward.reward_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_text(t)
        tag = Tag.create(text: t) unless tag
        RewardTag.create(tag_id: tag.id, reward_id: @reward.id)
      end

      flash[:notice] = "Premio generato correttamente"
      redirect_to "/easyadmin/reward/show/#{ @reward.id }"
    end
  end

  def edit
    @reward = Reward.find(params[:id])
    @currency_awards = Reward.where("spendable = TRUE")
    @tag_list_arr = Array.new
    @reward.reward_tags.each { |t| @tag_list_arr << t.tag.text }
    @tag_list = @tag_list_arr.join(",")
  end

  def update
    @reward = Reward.find(params[:id])
    
    unless @reward.update_attributes(params[:reward])
      @tag_list = params[:tag_list].split(",")

      render template: "/easyadmin/easyadmin/edit_reward"   
    else

      tag_list = params[:tag_list].split(",")
      @reward.reward_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_text(t)
        tag = Tag.create(text: t) unless tag
        RewardTag.create(tag_id: tag.id, reward_id: @reward.id)
      end

      flash[:notice] = "Premio aggiornato correttamente"
      redirect_to "/easyadmin/reward/show/#{ @reward.id }"
    end
  end
  
  def show
    @current_reward = Reward.find(params[:id])
    tag_list_arr = Array.new
    @current_reward.reward_tags.each { |t| tag_list_arr << t.tag.text }
    @tag_list = tag_list_arr.join(", ")

  end
end
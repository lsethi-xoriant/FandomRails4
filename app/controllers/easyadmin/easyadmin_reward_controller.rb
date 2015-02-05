class Easyadmin::EasyadminRewardController < Easyadmin::EasyadminController
  include EasyadminHelper
  include FilterHelper

  layout "admin"

  def index
    @reward_list = Reward.order("cost ASC")
  end

  def filter
    @reward_list = Reward.order("cost ASC")

    if params[:commit] == "APPLICA FILTRO"
      reward_ids = get_tagged_objects(@reward_list, params[:tag_list], RewardTag, 'reward_id', 'tag_id')
      @reward_list = Reward.where(:id => reward_ids).order("cost ASC")
    end

    if params[:commit] == "RESET"
      params[:tag_list] = ""
    end

    render template: "/easyadmin/easyadmin_reward/index"
  end

  def new
    @reward = Reward.new
    @currency_rewards = Reward.where("spendable = TRUE")
  end

  def clone
    @currency_rewards = Reward.where("spendable = TRUE")
    clone_reward(params)
  end

  def save
    @currency_rewards = Reward.where("spendable = TRUE")
    create_and_link_attachment(params[:reward], nil)
    @reward = Reward.create(params[:reward])
    tag_list = params[:tag_list].split(",")
    if @reward.errors.any?
      @tag_list = tag_list
      @extra_options = params[:extra_options]
      render template: "/easyadmin/easyadmin_reward/new"
    else
      update_and_redirect(tag_list, "Reward generato correttamente", @reward)
    end
  end

  def edit
    @reward = Reward.find(params[:id])
    if @reward.extra_fields.blank?
      @extra_options = {}
    else
      @extra_options = JSON.parse(@reward.extra_fields)
    end
    @currency_rewards = Reward.where("spendable = TRUE")
    @tag_list = get_reward_tag_list(@reward)
  end
  
  def update
    @reward = Reward.find(params[:id])
    create_and_link_attachment(params[:reward], @reward)
    tag_list = params[:tag_list].split(",")
    unless @reward.update_attributes(params[:reward])
      @tag_list = tag_list
      @extra_options = params[:extra_options]
      render template: "/easyadmin/easyadmin/edit_reward"   
    else
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
    reward.reward_tags.destroy_all
    tag_list.each do |t|
      tag = Tag.find_by_name(t)
      tag = Tag.create(name: t) unless tag
      RewardTag.create(tag_id: tag.id, reward_id: reward.id)
    end
  end
end
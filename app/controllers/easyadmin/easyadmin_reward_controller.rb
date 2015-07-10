class Easyadmin::EasyadminRewardController < Easyadmin::EasyadminController
  include EasyadminHelper
  include FilterHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :rewards
  end

  def index
    @reward_list = Reward.order("cost ASC")
  end

  def filter
    @reward_list = Reward.order("cost ASC")

    @name_filter = params[:name_filter]
    @title_filter = params[:title_filter]
    @cost_filter = params[:cost_filter]

    if params[:commit] == "APPLICA FILTRO"
      where_conditions = []
      reward_ids = get_tagged_objects(@reward_list, params[:tag_list], RewardTag, 'reward_id', 'tag_id')

      where_conditions << "name ILIKE '%#{@name_filter}%'" unless @name_filter.blank?
      where_conditions << "title ILIKE '%#{@title_filter.gsub("'", "''")}%'" unless @title_filter.blank?
      where_conditions << "cost = #{@cost_filter}" if ( !@cost_filter.blank? && /\A\d+\z/.match(@cost_filter) )
      where_conditions << "id IN (#{reward_ids.join(",")})" if reward_ids.any?
      @reward_list = Reward.where(where_conditions.join(" AND ")).order("cost ASC")
    end

    if params[:commit] == "RESET"
      @name_filter = @title_filter = @cost_filter = @tag_list = params[:tag_list] = ""
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
      @extra_options = @reward.extra_fields
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
    update_reward_tag(tag_list, reward)
    flash[:notice] = flash_message
    set_content_updated_at_cookie(reward.updated_at)
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
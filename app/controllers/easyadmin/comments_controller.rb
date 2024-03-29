class Easyadmin::CommentsController < Easyadmin::EasyadminController
  include EasyadminHelper
  include FandomUtils
  include RewardingSystemHelper
  include NoticeHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :comments
  end

  def update_comment_status
    current_comment = UserCommentInteraction.find(params[:comment_id])
    comment_initial_status = current_comment.approved

    current_comment.update_attributes(approved: params[:approved])

    interaction = current_comment.comment.interaction

    if current_comment.approved
      cta = interaction.call_to_action

      property = get_property()
      if property
        property_name = property.name
      end

      if anonymous_user.id != current_comment.user_id
        user_interaction, outcome = create_or_update_interaction(current_comment.user, interaction, nil, nil)
        if (JSON.parse(Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY).value)["comment_approved"] != false rescue true)
          create_notice(
            :user_id => current_comment.user_id, 
            :viewed => false, 
            :read => false, 
            :aux => {
              :ref_type => "user_comment_interaction", 
              :ref_id => current_comment.id, 
              :property => property_name, 
              :text => "Commento approvato su \"#{cta.title}\""
            }
          )
        end
      end

      unless cta.user_id.nil? # send notice to user_call_to_action owner
        if (JSON.parse(Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY).value)["user_cta_interactions"] != false rescue true)
          create_notice(
            :user_id => cta.user_id, 
            :viewed => false, 
            :read => false, 
            :aux => {
              :ref_type => "user_comment_interaction", 
              :ref_id => current_comment.id, 
              :property => property_name, 
              :text => "Nuovo commento approvato su \"#{cta.title}\""
            }
          )
        end
      end
      
    elsif comment_initial_status
      adjust_counter!(interaction, -1)
    end

    log_synced("change comment status from backoffice", approved: current_comment.approved, comment_id: current_comment.id)

    respond_to do |format|
      format.json { render :json => current_comment.to_json }
    end
  end

  def index_comment_not_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    where_conditions = write_where_conditions(params, "approved = false")
    @comment_not_approved = UserCommentInteraction.where(where_conditions).page(page).per(per_page).order("created_at DESC")

    @filters = set_filter_values(params)

    @page_size = @comment_not_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_to_be_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    where_conditions = write_where_conditions(params, "approved IS NULL")
    @comment_to_be_approved = UserCommentInteraction.where(where_conditions).page(page).per(per_page).order("created_at ASC")

    @filters = set_filter_values(params)

    @page_size = @comment_to_be_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    where_conditions = write_where_conditions(params, "approved = true")
    @comment_approved = UserCommentInteraction.where(where_conditions).page(page).per(per_page).order("created_at DESC")

    @filters = set_filter_values(params)

    @page_size = @comment_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
  def write_where_conditions(params, approved_cond)
    if params[:commit] == "RESET"
      params[:filters] = {}
    end
    where_conditions = approved_cond
    if params[:commit] != "RESET" && (!params[:filters]["cta_id"].blank? rescue false)
      call_to_action_ids = [params[:filters]["cta_id"].to_i]
    else
      call_to_action_ids = CallToAction.where("#{ params['cta'] == 'user_call_to_actions' ? 'user_id IS NOT NULL' : 'user_id IS NULL' }").pluck(:id)
    end
    comment_ids = Interaction.where("call_to_action_id IN (?) AND resource_type = 'Comment'", call_to_action_ids).pluck(:resource_id)
    if params[:filters]
      if params[:filters]["profanity_check"]
        comment_with_profanity_ids = []
        UserCommentInteraction.where(:comment_id => comment_ids, :approved => false).each do |user_comment_interaction|
          if (user_comment_interaction.aux["profanity"] == true rescue false)
            comment_with_profanity_ids << user_comment_interaction.id
          end
        end
      end
    end
    if params[:filters]
      unless params[:filters]["from_date"].blank?
        from_date = time_parsed_to_utc("#{params[:filters]["from_date"]} 00:00:00")
        where_conditions << " AND updated_at >= '#{from_date}'"
      end
      unless params[:filters]["to_date"].blank?
        to_date = time_parsed_to_utc("#{params[:filters]["to_date"]} 23:59:59")
        where_conditions << " AND updated_at <= '#{to_date}'"
      end
      where_conditions << " AND user_id IN (#{params[:filters]["user_id"]})" unless params[:filters]["user_id"].blank?
      where_conditions << " AND text ILIKE '%#{params[:filters]["text"].gsub("'", "''")}%'" unless params[:filters]["text"].blank?
    end
    where_conditions << " AND comment_id IN (#{ comment_ids.empty? ? "-1" : comment_ids.join(",") })"
    where_conditions << " AND id in (#{comment_with_profanity_ids.join(",")})" unless comment_with_profanity_ids.blank?
    where_conditions
  end

end
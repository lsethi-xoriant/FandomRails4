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
    current_comment.update_attributes(approved: params[:approved])

    interaction = current_comment.comment.interaction

    if current_comment.approved
      adjust_counter!(interaction, 1)
      cta = interaction.call_to_action

      if anonymous_user.id != current_comment.user_id
        user_interaction, outcome = create_or_update_interaction(current_comment.user, interaction, nil, nil)

        html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_comment_approved_template", locals: { cta: cta }, layout: false, formats: :html

        if JSON.parse(Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY).value)['comment_approved'] != false
          create_notice(:user_id => current_comment.user_id, :html_notice => html_notice, :viewed => false, :read => false)
        end
      end

      unless cta.user_id.nil? # user_call_to_action
        if JSON.parse(Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY).value)['user_cta_interactions'] != false
          html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_interaction_on_ugc_approved_template", locals: { cta: cta, interaction_type: "commento" }, layout: false, formats: :html
          create_notice(:user_id => cta.user_id, :html_notice => html_notice, :viewed => false, :read => false)
        end
      end

    else
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

    @user_id_filter = params[:user_id_filter]
    @cta_id_filter = params[:cta_id_filter]
    @text_filter = params[:text_filter]

    @page_size = @comment_not_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_to_be_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    where_conditions = write_where_conditions(params, "approved IS NULL")
    @comment_to_be_approved = UserCommentInteraction.where(where_conditions).page(page).per(per_page).order("created_at ASC")

    @user_id_filter = params[:user_id_filter]
    @cta_id_filter = params[:cta_id_filter]
    @text_filter = params[:text_filter]

    @page_size = @comment_to_be_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    where_conditions = write_where_conditions(params, "approved = true")
    @comment_approved = UserCommentInteraction.where(where_conditions).page(page).per(per_page).order("created_at DESC")

    @user_id_filter = params[:user_id_filter]
    @cta_id_filter = params[:cta_id_filter]
    @text_filter = params[:text_filter]

    @page_size = @comment_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
  def write_where_conditions(params, approved_cond)
    params[:user_id_filter] = params[:cta_id_filter] = params[:text_filter] = nil unless params[:commit] != "RESET"
    where_conditions = approved_cond
    if params[:commit] != "RESET" && !params[:cta_id_filter].blank?
      call_to_action_ids = [params[:cta_id_filter].to_i]
    else
      call_to_action_ids = CallToAction.where("#{ params['cta'] == 'user_call_to_actions' ? 'user_id IS NOT NULL' : 'user_id IS NULL' }").pluck(:id)
    end
    comment_ids = Interaction.where("call_to_action_id IN (?) AND resource_type = 'Comment'", call_to_action_ids).pluck(:resource_id)

    where_conditions << " AND user_id IN (#{params[:user_id_filter]})" unless params[:user_id_filter].blank?
    where_conditions << " AND comment_id IN (#{ comment_ids.empty? ? "-1" : comment_ids.join(",") })"
    where_conditions << " AND text ILIKE '%#{params[:text_filter]}%'" unless params[:text_filter].blank?
    where_conditions
  end

end
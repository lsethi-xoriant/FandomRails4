class Easyadmin::CommentsController < Easyadmin::EasyadminController
  include EasyadminHelper
  include FandomUtils
  include RewardingSystemHelper
  include NoticeHelper

  layout "admin"

  def authorize_user
    authorize! :manage, :comments
  end

  def update_comment_status
    current_comment = UserCommentInteraction.find(params[:comment_id])
    current_comment.update_attributes(approved: params[:approved])

    if current_comment.approved

      if anonymous_user.id != current_comment.user_id
        interaction = current_comment.comment.interaction
        user_interaction, outcome = create_or_update_interaction(current_comment.user, interaction, nil, nil)
        
        cta = user_interaction.interaction.call_to_action

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

    end

    log_synced("change comment status from backoffice", approved: current_comment.approved, comment_id: current_comment.id)

    respond_to do |format|
      format.json { render :json => current_comment.to_json }
    end
  end

  def index_comment_not_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @id_cta_not_approved_filter = params[:id_cta_not_approved_filter]
    where_condition = write_where_condition(:id_cta_not_approved_filter, "approved = false")
    @comment_not_approved = UserCommentInteraction.where(where_condition, params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_not_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_to_be_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @id_cta_to_be_approved_filter = params[:id_cta_to_be_approved_filter]
    where_condition = write_where_condition(:id_cta_to_be_approved_filter, "approved IS NULL")
    @comment_to_be_approved = UserCommentInteraction.where(where_condition, params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_to_be_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @id_cta_approved_filter = params[:id_cta_approved_filter]
    where_condition = write_where_condition(:id_cta_approved_filter, "approved = true")
    @comment_approved = UserCommentInteraction.where(where_condition, params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
  def write_where_condition(param, approved_cond)
    if params[param].present? && params[:commit] != "Reset"
      interaction = Interaction.where(:call_to_action_id => params[param], :resource_type => 'Comment')
      comment_id = interaction.present? ? interaction.first.resource_id : -1
      return comment_id.blank? ? approved_cond : approved_cond << " AND comment_id = #{comment_id}"
    else
      return approved_cond
    end
  end

end
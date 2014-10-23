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
        user_interaction, outcome = UserInteraction.create_or_update_interaction(current_comment.user_id, interaction.id, nil, nil)

        create_notice(:user_id => current_comment.user_id, :html_notice => current_comment.text, :viewed => false, :read => false)

        outcome = compute_and_save_outcome(user_interaction)
        # TODO: notify outcome
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
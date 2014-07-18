class Easyadmin::CommentsController < Easyadmin::EasyadminController
  include EasyadminHelper
  include FandomUtils
  include RewardingSystemHelper

  layout "admin"

  def authorize_user
    authorize! :manage, :comments
  end

  def update_comment_status
    current_comment = UserComment.find(params[:comment_id])
    current_comment.update_attributes(approved: params[:approved])

    if current_comment.approved

      if anonymous_user.id != current_comment.user_id
        interaction = current_comment.comment.interaction
        user_interaction = UserInteraction.create_or_update_interaction(current_comment.user_id, interaction.id)

        Notice.create(:user_id => current_comment.user_id, :html_notice => current_comment.text, :viewed => false, :read => false)

        outcome = compute_and_save_outcome(user_interaction)
        # TODO: notify outcome
      end    

    end

    respond_to do |format|
      format.json { render :json => current_comment.to_json }
    end
  end

  def index_comment_not_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @comment_not_approved = UserComment.where("approved=false", params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_not_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_to_be_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @comment_to_be_approved = UserComment.where("approved IS NULL", params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_to_be_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @comment_approved = UserComment.where("approved=true", params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
end
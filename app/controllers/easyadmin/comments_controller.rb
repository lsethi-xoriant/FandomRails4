require 'fandom_utils'

class Easyadmin::CommentsController < Easyadmin::EasyadminController
  include EasyadminHelper
  include FandomUtils

  layout "admin"

  def authorize_user
    authorize! :manage, :comments
  end

  def update_comment_status
    comm = UserComment.find(params[:comment_id])
    comm.update_attributes(published_at: DateTime.now, deleted: params[:pub_or_hide] == "hide")

    if !comm.deleted
      Notice.create(:user_id => comm.user_id, :html_notice => comm.text, :viewed => false, :read => false)
    end

    respond_to do |format|
      format.json { render :json => comm.to_json }
    end
  end

  def index_comment_not_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @comment_not_approved = UserComment.where("deleted=true", params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_not_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_to_be_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @comment_to_be_approved = UserComment.where("published_at IS NULL", params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_to_be_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @comment_approved = UserComment.where("published_at IS NOT NULL AND deleted=false", params[:id]).page(page).per(per_page).order("created_at ASC")

    @page_size = @comment_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
end
class Easyadmin::TagController < ApplicationController
  include EasyadminHelper

  layout "admin"

  def index
    @tags = Tag.all
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.create(params[:tag])
    if @tag.errors.any?
      @tag_list = params[:tag_list].split(",")
      render template: "/easyadmin/tag/new"     
    else

      tag_list = params[:tag_list].split(",")
      @tag.tags_tags.delete_all
      tag_list.each do |t|
        tag_tag = Tag.find_by_name(t)
        tag_tag = Tag.create(name: t) unless tag_tag
        TagsTag.create(tag_id: @tag.id, other_tag_id: tag_tag.id)
      end

      flash[:notice] = "Tag generato correttamente"
      redirect_to "/easyadmin/tag/#{ @tag.id }"
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @tag_list_arr = Array.new
    @tag.tags_tags.each { |t| @tag_list_arr << t.other_tag.name }
    @tag_list = @tag_list_arr.join(",")
  end
  
  def update
    @tag = Tag.find(params[:id])
    unless @tag.update_attributes(params[:tag])
      @tag_list = params[:tag_list].split(",")   
      render template: "/easyadmin/tag/#{@tag.id}/edit"   
    else
      tag_list = params[:tag_list].split(",")
      @tag.tags_tags.delete_all
      tag_list.each do |t|
        tag_tag = Tag.find_by_name(t)
        tag_tag = Tag.create(name: t) unless tag_tag
        TagsTag.create(tag_id: @tag.id, other_tag_id: tag_tag.id)
      end
      flash[:notice] = "Tag aggiornato correttamente"
      redirect_to "/easyadmin/tag/#{ @tag.id }"
    end
  end
  
  def show
    @tag = Tag.find(params[:id])
  end

end
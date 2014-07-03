class Easyadmin::TagController < ApplicationController
  include EasyadminHelper
  include GraphHelper

  layout "admin"

  def index
    @tags = Tag.all
  end

  def new
    @tag = Tag.new
  end

  def create
    
    successfull_transation = true
    
    ActiveRecord::Base.transaction do
      
      begin
    
        @tag = Tag.create(params[:tag])
        if @tag.errors.any?
          successfull_transation = false
          @tag_list = params[:tag_list]
        else
          tag_list = params[:tag_list].split(",")
          @tag.tags_tags.delete_all
          tag_list.each do |t|
            tag_tag = Tag.find_by_name(t)
            tag_tag = Tag.create(name: t) unless tag_tag
            TagsTag.create(tag_id: @tag.id, other_tag_id: tag_tag.id)
          end
          
          if !validate_tag_references(@tag)
            raise ActiveRecord::Rollback
          end

        end
      
      rescue
        successfull_transation = false
        flash[:error] = "Errore hai generato un ciclo nel riferimento tag"
        raise ActiveRecord::Rollback
      end
    
    end
    
    if successfull_transation
      flash[:notice] = "Tag generato correttamente"
      redirect_to "/easyadmin/tag/#{ @tag.id }"
    else
      @tag_list = params[:tag_list]
      render template: "/easyadmin/tag/new"
    end
    
  end

  def edit
    @tag = Tag.find(params[:id])
    @tag_list_arr = Array.new
    @tag.tags_tags.each { |t| @tag_list_arr << t.other_tag.name }
    @tag_list = @tag_list_arr.join(",")
  end
  
  def update
    successfull_transation = true
    
    ActiveRecord::Base.transaction do
      
      begin
        
        @tag = Tag.find(params[:id])
        unless @tag.update_attributes(params[:tag])
          successfull_transation = false
          @tag_list = params[:tag_list]  
        else
          tag_list = params[:tag_list].split(",")
          @tag.tags_tags.delete_all
          tag_list.each do |t|
            tag_tag = Tag.find_by_name(t)
            tag_tag = Tag.create(name: t) unless tag_tag
            TagsTag.create(tag_id: @tag.id, other_tag_id: tag_tag.id)
          end
          
          if !validate_tag_references(@tag)
            raise ActiveRecord::Rollback
          end
        
        end
        
      rescue
        successfull_transation = false
        flash[:error] = "Errore hai generato un ciclo nel riferimento tag"
        raise ActiveRecord::Rollback
      end
    
    end
    
    if successfull_transation
      flash[:notice] = "Tag aggiornato correttamente"
      redirect_to "/easyadmin/tag/#{ @tag.id }"
    else
      @tag_list = params[:tag_list]
      render "edit"
    end
    
  end
  
  def show
    @tag = Tag.find(params[:id])
  end

end
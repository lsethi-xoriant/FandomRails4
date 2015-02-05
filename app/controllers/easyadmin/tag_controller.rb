class Easyadmin::TagController < Easyadmin::EasyadminController
  include EasyadminHelper
  include GraphHelper
  include FilterHelper

  layout "admin"

  def index
    @tags = Tag.all
  end

  def filter
    @tags = Tag.scoped

    @title_filter = params[:title_filter]
    @description_filter = params[:description_filter]
    @tag_list = params[:tag_list]

    if params[:commit] == "APPLICA FILTRO"

      tags_ids = get_tagged_objects(@tags, params[:tag_list], TagsTag, 'tag_id', 'other_tag_id')

      where_conditions = "true"
      where_conditions << " AND title ILIKE '%#{@title_filter}%'" unless @title_filter.blank?
      where_conditions << " AND description ILIKE '%#{@description_filter}%'" unless @description_filter.blank?
      unless @tag_list.blank?
        where_conditions << (tags_ids.blank? ? " AND id IS NULL" : " AND id in (#{tags_ids.inspect[1..-2]})")
      end

      @tags = Tag.where(where_conditions)

    else
      @tag_list = nil
    end
    render "index"
  end

  def new
    @tag = Tag.new
  end

  def create_or_update(template_name, &create_or_update_block)

    ActiveRecord::Base.transaction do
      begin
        success = yield create_or_update_block
        if !success
          @tag_list = params[:tag_list]
          render template_name
        else
          add_tags_tags_and_check_cycle()
          flash[:notice] = "Tag generato correttamente"
          redirect_to "/easyadmin/tag/#{ @tag.id }"
        end

      rescue Exception => e
        # TODO: fix error message
        flash[:error] = "Errore hai generato un ciclo nel riferimento tag: #{e}"
        @tag_list = params[:tag_list]
        render template_name
        raise ActiveRecord::Rollback
      end
    end

  end

  def create
    create_or_update("new") do
      create_and_link_attachment(params[:tag], nil)
      @tag = Tag.create(params[:tag])
      @tag.errors.empty?
    end
  end

  def update
    create_or_update("edit") do
      @tag = Tag.find(params[:id])
      create_and_link_attachment(params[:tag], @tag)
      old_name = @tag.name
      new_name = params[:tag][:name]

      if old_name == new_name
        @tag.update_attributes(params[:tag])
      else
        change_name_if_not_locked(@tag, params)
      end

    end
  end

  def change_name_if_not_locked(tag, new_tag_params)
    if (tag.locked && new_tag_params[:tag]["locked"] == "1")
      flash[:error] = "Non puoi modificare il nome di un tag contrassegnato come locked"
      false
    else
      tag.update_attributes(new_tag_params[:tag])
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @tag_list_arr = Array.new
    @tag.tags_tags.each { |t| @tag_list_arr << t.other_tag.name }
    @tag_list = @tag_list_arr.join(",")
  end

  def add_tags_tags_and_check_cycle
    tag_list = params[:tag_list].split(",")
    @tag.tags_tags.delete_all
    tag_list.each do |t|
      tag_tag = Tag.find_by_name(t)
      tag_tag = Tag.create(name: t) unless tag_tag
      TagsTag.create(tag_id: @tag.id, other_tag_id: tag_tag.id)
    end

    if tags_cyclic?(@tag)
      raise ActiveRecord::Rollback
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def clone
    tag = Tag.find(params[:id])
    tag.name = "Copy of "+ tag.name
    tag_attributes = tag.attributes
    tag_attributes.delete("id")
    tag_copy = Tag.new(tag_attributes, :without_protection => true)
    clone_tags_tags(tag_copy, tag)
    @tag = tag_copy
    @cloning = true
    tag_array = Array.new
    @tag.tags_tags.each { |t| tag_array << t.other_tag.name }
    @tag_list = tag_array.join(",")
    params[:id] = @tag.id
    params[:extra_fields] = JSON.parse(@tag.extra_fields) if @tag.extra_fields
    create_and_link_attachment(params, @tag)
    render "new"
  end

  def clone_tags_tags(new_tag, old_tag)
    old_tag.tags_tags.each do |t|
      new_tag.tags_tags.build(tag_id: new_tag.id, other_tag_id: t.other_tag_id)
    end
  end

end
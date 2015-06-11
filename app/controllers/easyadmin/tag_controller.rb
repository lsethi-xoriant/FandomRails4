class Easyadmin::TagController < Easyadmin::EasyadminController
  include EasyadminHelper
  include GraphHelper
  include FilterHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :tags
  end

  def index
    @tags = Tag.all
  end

  def filter
    @tags = Tag.where(nil)

    @title_filter = params[:title_filter]
    @description_filter = params[:description_filter]
    @tag_list = params[:tag_list]

    if params[:commit] == "APPLICA FILTRO"

      tags_ids = get_tagged_objects(@tags, params[:tag_list], TagsTag, 'tag_id', 'other_tag_id')

      where_conditions = "true"
      where_conditions << " AND title ILIKE '%#{@title_filter.gsub("'", "''")}%'" unless @title_filter.blank?
      where_conditions << " AND description ILIKE '%#{@description_filter.gsub("'", "''")}%'" unless @description_filter.blank?
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
          cookies[:updated_at] = Time.now
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

  def edit
    @tag = Tag.find(params[:id])
    @tag_list_arr = Array.new
    @tag.tags_tags.each { |t| @tag_list_arr << t.other_tag.name }
    @tag_list = @tag_list_arr.join(",")
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

  def add_tags_tags_and_check_cycle
    tag_list = params[:tag_list].split(",")
    @tag.tags_tags.delete_all
    tag_list.each do |t|
      tag_tag = Tag.find_by_name(t)
      tag_tag = Tag.create(title: t, name: t, slug: t) unless tag_tag
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
    params[:extra_fields] = @tag.extra_fields
    create_and_link_attachment(params, @tag)
    render "new"
  end

  def clone_tags_tags(new_tag, old_tag)
    old_tag.tags_tags.each do |t|
      new_tag.tags_tags.build(tag_id: new_tag.id, other_tag_id: t.other_tag_id)
    end
  end

  def retag_tag
    if params[:commit] == "RITAGGA"

      if params[:old_tag].blank?
        msg = "Tag da ricercare non inseriti"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      end
      if params[:new_tag].blank?
        msg = "Nuovo tag non inserito"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      elsif params[:new_tag].include? ","
        msg = "Inserire un solo nuovo tag"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      elsif params[:old_tag].present? && params[:new_tag].present? 
        update_class_tag_table(CallToActionTag, "call_to_action_id", "tag_id")
        update_class_tag_table(RewardTag, "reward_id", "tag_id")

        update_tags_tag_table()
      end

    end
  end

  def ordering

    @ordered_elements = Array.new
    @call_to_action_names = Array.new
    @reward_names = Array.new
    @tag_names = Array.new

    if params[:commit] == "CERCA"

      if params[:tag].include? ","
        msg = "Inserire un solo tag"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      else
        tag = Tag.find_by_name(params[:tag])
        if !tag
          msg = "Non esistono tag con nome '#{params[:tag]}'"
          flash.now[:error] = (flash.now[:error] ||= []) << msg
        else
          tag_extra_fields = tag.extra_fields
          if tag_extra_fields.present?
            ordering = tag_extra_fields["ordering"]
            if ordering
              @ordered_elements = ordering.gsub(/\s+/, "").split(",")
            end
          end

          tag_id = tag.id

          CallToActionTag.where(:tag_id => tag_id).each do |ct|
            if ct.call_to_action_id
              name = CallToAction.find(ct.call_to_action_id).name
              @call_to_action_names << name unless @ordered_elements.include?(name)
            end
          end

          reward_ids = RewardTag.where(:tag_id => tag_id).each do |rt|
            name = Reward.find(rt.reward_id).name
            @reward_names << name unless @ordered_elements.include?(name)
          end

          tag_ids = TagsTag.where(:other_tag_id => tag_id).each do |tt|
            name = Tag.find(tt.tag_id).name
            @tag_names << name unless @ordered_elements.include?(name)
          end
        end
      end

    elsif params[:commit] == 'SALVA ORDINAMENTO'

      ordering_array = JSON.parse(params["json_ordering"])["lists"]["orderedElements"]
      ordering = ordering_array.map { |element| element.to_s }.join(",")

      tag = Tag.find_by_name(params[:tag])
      extra_fields = tag.extra_fields
      extra_fields["ordering"] = ordering
      if tag.update_attribute(:extra_fields, extra_fields)
        flash[:notice] = "Ordinamento per il tag '#{tag.name}' salvato con successo"
      else
        flash.now[:error] << "Errore nel salvataggio dell'ordinamento per il tag '#{tag.name}'"
      end
    end

  end

  def update_updated_at
    if params[:tag_ids] and params[:updated_at]
      params[:tag_ids].split(",").each do |tag_id|
        update_updated_at_recursive(tag_id, params[:updated_at])
      end
    end
    cookies.delete :updated_at
    respond_to do |format|
      format.json { render :json => params[:updated_at].to_json }
    end
  end

  def update_updated_at_recursive(tag_id, updated_at)
    tag = Tag.find(tag_id)
    tag.updated_at = updated_at
    tag.save
    TagsTag.where("tag_id = #{tag_id}").each do |tags_tag|
      update_updated_at_recursive(tags_tag.other_tag_id, updated_at)
    end
  end

  def update_tag
    @tag = Tag.find(params[:id])
    unless @tag.update_attributes(params[:tag])  
      render template: "/easyadmin/easyadmin/edit_tag"     
    else
      flash[:notice] = "Tag aggiornato correttamente"
      redirect_to "/easyadmin/tag"
    end
  end

  def tag_cta
    @tag_list_arr = Array.new
    CallToAction.find(params[:id]).call_to_action_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")
    @page = params[:page]
  end

  def tag_cta_update
    @cta = CallToAction.find(params[:id])
    tag_list = params[:tag_list].split(",")

    @cta.call_to_action_tags.delete_all

    tag_list.each do |t|
      tag = Tag.find_by_name(t)
      tag = Tag.create(title: t, name: t, slug: t) unless tag
      CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
    end
    flash[:notice] = "CallToAction taggata"
    cookies[:updated_at] = Time.now
    unless params[:page].blank?
      redirect_to params[:page]
    else
      redirect_to "/easyadmin/cta/tag/#{ @cta.id }"
    end
  end

  def update_class_tag_table(class_name, class_id_field, tag_id_field)
    id_objects_to_update = class_name.pluck(class_id_field)

    old_tags = params[:old_tag].split(",").map { |name|
        Tag.find_by_name(name)
    }

    old_tags.each do |old_tag|
      id_objects_tagged = class_name.where("#{tag_id_field} = ?", old_tag.id).pluck(class_id_field)
      id_objects_to_update = id_objects_to_update & id_objects_tagged # intersection
    end

    id_objects_to_update.each do |object_id|
      # class_name.delete_all(["#{class_id_field} = ?", object_id]) # uncomment if old tagging must be dismissed
      new_tag = Tag.find_by_name(params[:new_tag])
      new_tag = Tag.create(name: params[:new_tag]) unless new_tag

      if class_name.where("#{class_id_field} = ? AND #{tag_id_field} = ?", object_id, new_tag.id).count == 0
        object_tag = class_name.new
        object_tag[class_id_field] = object_id
        object_tag[tag_id_field] = new_tag.id
        object_tag.save
      end
    end

    if id_objects_to_update.size > 0
      flash.now[:notice] = (flash.now[:notice] ||= []) << "#{class_name.to_s.slice(0..-4)} ritaggati/e"
    end
  end

  def update_tags_tag_table

    id_objects_to_update = []

    params[:old_tag].split(",").map { |name|
      other_tag = Tag.find_by_name(name)
      id_objects_to_update = id_objects_to_update | TagsTag.where(:other_tag_id => other_tag.id).pluck(:tag_id)
    }

    id_objects_to_update.each do |object_id|
      # TagsTag.delete_all(["tag_id = ?", object_id]) # uncomment if old tagging must be dismissed
      new_tag = Tag.find_by_name(params[:new_tag])
      new_tag = Tag.create(name: params[:new_tag]) unless new_tag

      if TagsTag.where("tag_id = ? AND other_tag_id = ?", object_id, new_tag.id).count == 0
        object_tag = TagsTag.new
        object_tag.tag_id = object_id
        object_tag.other_tag_id = new_tag.id
        object_tag.save
      end
    end

    if id_objects_to_update.size > 0
      flash.now[:notice] = (flash.now[:notice] ||= []) << "Tags ritaggati/e"
    end
  end

end
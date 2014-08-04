class BrowseController < ApplicationController
  
  def index
    @original_show = Tag.find_by_name("OriginalShow")
    @original_show_contents = get_original_show_content(@original_show)
    recent = get_recent_ctas()
    @recent_contents = prepare_contents(recent)
  end
  
  def index_category
    tag = Tag.find(params[:id])
    @category = tag.to_category
    tags = get_tags_with_tag(tag.name).order("tags.created_at DESC")
    ctas = get_ctas_with_tag(tag.name).order("call_to_actions.created_at DESC")
    @contents = merge_contents(ctas, tags)
  end

  def get_original_show_content(original_show)
    contents = Array.new
    original_show.tag_fields.find_by_name("contents").value.split(",").each do |name|
      cta = CallToAction.find_by_name(name)
      if cta
        contents << cta
      else
        tag = Tag.find_by_name(name)
        contents << tag
      end
    end
    @contents = prepare_contents(contents)
  end
  
  def get_recent_ctas
    CallToAction.active.limit(6)
  end
  
  def view_all
    @tag = Tag.find(params[:id_cat])
    tags = get_tags_with_tag(@tag.name).order("tags.created_at DESC")
    ctas = get_ctas_with_tag(@tag.name).order("call_to_actions.created_at DESC")
    @contents = merge_contents(ctas,tags)
  end
  
  def merge_contents(ctas,tags)
    merged = (ctas + tags).sort_by(&:created_at)
    prepare_contents(merged)
  end
  
  def prepare_contents(elements)
    contents = []
    elements.each do |element|
      contents << element.to_category
    end
    contents
  end
  
  def search
    
  end
  
end

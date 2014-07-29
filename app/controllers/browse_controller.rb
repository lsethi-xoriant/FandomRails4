class BrowseController < ApplicationController
  
  def index
    @original_show = Tag.find_by_name("OriginalShow")
    @original_show_contents = get_original_show_content(@original_show)
    @recent_contents = get_recent_ctas()
  end
  
  def search
    
  end

  def get_original_show_content(original_show)
    contents = Array.new
    original_show.tag_fields.find_by_name("contents").value.split(",").each do |c|
      cta = CallToAction.find_by_name(c)
      if cta
        contents << cta
      else
        tag = Tag.find_by_name(c)
        contents << tag
      end
    end
    contents
  end
  
  def get_recent_ctas
    CallToAction.active.limit(6)
  end
  
  def view_all
    @tag_name = Tag.find(params[:id]).name
    tags = get_tags_with_tag(@tag_name).order("tags.created_at DESC")
    ctas = get_ctas_with_tag(@tag_name).order("call_to_actions.created_at DESC")
    debugger
    @contents = merge_contents(ctas,tags)
  end
  
  def merge_contents(ctas,tags)
    (ctas + tags).sort_by(&:created_at)
  end
  
end

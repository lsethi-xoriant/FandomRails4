class Sites::Disney::BrowseController < BrowseController
  include DisneyHelper
  
  def full_search
    debugger
    @contents = get_contents_with_match(params[:query])
    if @contents.empty?
      redirect_to "#{get_disney_property_root_path}/browse"
    end
  end
  
end
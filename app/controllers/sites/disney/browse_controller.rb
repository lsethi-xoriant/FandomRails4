class Sites::Disney::BrowseController < BrowseController
  include DisneyHelper
  
  def full_search
    contents = get_contents_with_match(params[:query])
    @total = contents.count
    @contents = contents.slice(0,12)
    @query = params[:query]
    if @contents.empty?
      redirect_to "#{get_disney_property_root_path}/browse", :flash => { :notice => "Non ci sono risultati!" }
    end
  end
  
end
class Sites::Disney::BrowseController < BrowseController
  include DisneyHelper
  
  def full_search
    contents, total = get_contents_with_match(params[:query])
    @total = total
    @contents = prepare_contents(contents)
    @query = params[:query]
    if @contents.empty?
      redirect_to "#{get_disney_property_root_path}/browse", :flash => { :notice => "Non ci sono risultati, potrebbero interessarti alcuni di questi contenuti." }
    end
  end
  
end
class Sites::Disney::BrowseController < BrowseController
  include DisneyHelper
  
  def full_search
    contents, total = get_contents_with_match(params[:query])
    @total = total
    contents = prepare_contents(contents)
    
    if FULL_SEARCH_CTA_STATUS_ACTIVE
      cta_ids = []
      contents.each do |content|
        if content["type"] == "cta"
          cta_ids << content["id"]
        end
      end
      cta_statuses = {}
      unless cta_ids.empty?
        cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
      end
      contents.each do |content|
        if content["type"] == "cta"
          content["status"] = cta_statuses[content["id"].to_i]
        end
      end
      @contents = contents
    else
      @contens = contents
    end
    
    @query = params[:query]
    if @contents.empty?
      redirect_to "#{get_disney_property_root_path}/browse", :flash => { :notice => "Non ci sono risultati, potrebbero interessarti alcuni di questi contenuti." }
    end
  end
  
end
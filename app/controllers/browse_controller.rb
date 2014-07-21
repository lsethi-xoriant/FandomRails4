class BrowseController < ApplicationController
  
  def index
    @calltoactions = CallToAction.all
  end
  
  def search
    
  end

end

class Sites::Forte::UploadInteractionController < ApplicationController
  
  def new
    calltoaction = CallToAction.find_by_name("upload-ugc")
    @upload_interaction = calltoaction.interactions.find_by_resource_type("Upload")
    render template: "/upload_interaction/new"
  end
  
end


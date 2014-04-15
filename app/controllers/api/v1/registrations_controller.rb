class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token
  before_filter :check_application_client

  respond_to :json
  
  def create
    build_resource(params[:user])
    if resource.save
      render :status => 200,
           :json => { success: true,
                      info: "registered",
                      data: { user: resource, access_token: Doorkeeper::AccessToken.create(application_id: app_id, resource_owner_id: resource.id).token }}
    else
      render :status => :unprocessable_entity,
             :json => { :success => false,
                        :info => resource.errors,
                        :data => {} }
    end
  end

end

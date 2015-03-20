class Sites::Disney::Easyadmin::SettingsController < Easyadmin::EasyadminController
  include EasyadminHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :settings
  end

  def properties_settings
    setting = Setting.find_by_key(PROPERTIES_LIST_KEY)
    @saved = true
    if !setting
      @setting = Setting.create(:key => PROPERTIES_LIST_KEY, :value => "violetta")
      @setting_value = @setting.value
    else
      @setting_value = setting.value
    end
    render template: "/easyadmin/settings/properties_settings"
  end

  def save_properties_settings
    setting = Setting.find_by_key(params[:key])
    value = params[:setting].gsub(" ", "")
    setting.update_attribute(:value, value)
    @saved = true
    @setting_value = setting.value
    flash[:notice] = "Modifiche salvate correttamente"
    render template: "/easyadmin/settings/properties_settings"
  end

end
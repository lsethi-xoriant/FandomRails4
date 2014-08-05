class Easyadmin::SettingsController < ApplicationController
  include EasyadminHelper

  layout "admin"
  
  def browse_settings
    setting = Setting.find_by_key(BROWSE_SETTINGS_KEY)
    @saved = true
    if !setting
      @setting = Setting.create(:key => BROWSE_SETTINGS_KEY, :value => "")
      @setting_value = @setting.value
    else
      @setting_value = setting.value
    end
  end
  
  def save_browse_settings
    setting = Setting.find_by_key(params[:key])
    setting.update_attribute(:value, params[:setting])
    @saved = true
    @setting_value = setting.value
    flash[:notice] = "Modifiche salvate correttamente"
    render template: "/easyadmin/settings/browse_settings"
  end

end
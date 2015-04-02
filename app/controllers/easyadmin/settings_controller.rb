class Easyadmin::SettingsController < Easyadmin::EasyadminController
  include EasyadminHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :settings
  end

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

  def ranking_settings
    setting = Setting.find_by_key(RANKING_SETTINGS_KEY)
    @saved = true
    if !setting
      @setting = Setting.create(:key => RANKING_SETTINGS_KEY, :value => "")
      @setting_value = @setting.value
    else
      @setting_value = setting.value
    end
  end

  def save_ranking_settings
    setting = Setting.find_by_key(params[:key])
    setting.update_attribute(:value, params[:setting])
    @saved = true
    @setting_value = setting.value
    flash[:notice] = "Modifiche salvate correttamente"
    render template: "/easyadmin/settings/ranking_settings"
  end

  def notifications_settings
    setting = Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY)
    @saved = true
    if !setting
      @setting = Setting.create(:key => NOTIFICATIONS_SETTINGS_KEY, :value => "{\"upload_approved\":true, \"comment_approved\":true, \"user_cta_interactions\":true}")
      @setting_value = { "upload_approved" => true, "comment_approved" => true, "user_cta_interactions" => true }
    else
      @setting_value = JSON.parse(setting.value)
    end
  end

  def save_notifications_settings
    setting = Setting.find_by_key(params[:key])
    @setting_value =  { "upload_approved" => params[:upload_approved] == "true", 
                        "comment_approved" => params[:comment_approved] == "true",
                        "user_cta_interactions" => params[:user_cta_interactions] == "true"
                      }
    setting.update_attribute(:value, @setting_value.to_json)
    @saved = true
    flash[:notice] = "Modifiche salvate correttamente"
    render template: "/easyadmin/settings/notifications_settings"
  end

  def profanities_settings
    activation_setting = Setting.find_by_key(ACTIVE_PROFANITIES_SETTINGS_KEY)
    words_setting = Setting.find_by_key(PROFANITIES_SETTINGS_KEY)
    @saved = true
    @activation_setting = activation_setting ? activation_setting.value : Setting.create(:key => ACTIVE_PROFANITIES_SETTINGS_KEY, :value => false)
    @words_setting = words_setting ? words_setting.value : Setting.create(:key => PROFANITIES_SETTINGS_KEY, :value => "")
  end

  def save_profanities_settings
    active_setting = Setting.find_by_key(params[:active_key])
    setting = Setting.find_by_key(params[:key])
    debugger
    active_setting.update_attribute(:value, params[:activation_setting] == "true")
    setting.update_attribute(:value, params[:words_setting])
    @saved = true
    @activation_setting = params[:activation_setting] == "true"
    @words_setting = params[:words_setting]
    flash[:notice] = "Impostazioni salvate correttamente"
    render template: "/easyadmin/settings/profanities_settings"
  end

end